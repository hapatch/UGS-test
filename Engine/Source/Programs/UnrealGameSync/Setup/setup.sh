#!/bin/bash

# Build-time seed script - runs once during `docker build`, baking a small Unreal-project-shaped depot into the
# image so every `docker run` starts from the same known state. Modeled on
# Engine/Source/Programs/Shared/EpicGames.Perforce.Fixture/setup.sh, but with a project layout UnrealGameSync
# actually expects (a .uproject, Engine/Build/Build.version) instead of a generic depot.

set -euo pipefail

export PORT=1666
export P4PORT=localhost:$PORT

mkdir -p "$P4ROOT"
p4d -r "$P4ROOT" -p $PORT &
P4D_PID=$!

echo "Waiting for server to listen on port $PORT..."
for i in $(seq 1 60); do
	if p4 -p localhost:$PORT info > /dev/null 2>&1; then
		break
	fi
	if ! kill -0 $P4D_PID 2>/dev/null; then
		echo "p4d exited before it started listening on port $PORT" >&2
		exit 1
	fi
	if [ "$i" -eq 60 ]; then
		echo "Timed out waiting for p4d to listen on port $PORT" >&2
		exit 1
	fi
	sleep 0.5
done

# Create a dummy user (no password - default security level, same as the fixture)
p4 user -f -i << EOF
User:	test.user
Type:	standard
Email:	test.user@localhost
FullName:	Test User
AuthMethod:	perforce
EOF

export P4USER=test.user

# Create a stream depot
p4 depot -i << EOF
Depot:          UGSTest
Owner:          test.user
Description:
                Test depot for manual UnrealGameSync testing.

Type:           stream
StreamDepth:    //UGSTest/1
Map:            UGSTest/...
EOF

# Create the mainline stream
p4 stream -i << EOF
Stream: //UGSTest/Main
Owner:  test.user
Name:   Main
Parent: none
Type:   mainline
Description:
        Main stream for the UGSTest depot.

Options:        allsubmit unlocked notoparent nofromparent mergedown
ParentView:     inherit
Paths:
        share ...
EOF

export P4CLIENT=seed-client
export CLIENT_ROOT=/tmp/$P4CLIENT
p4 client -i << EOF
Client: $P4CLIENT
Root: $CLIENT_ROOT
Stream: //UGSTest/Main
EOF

mkdir -p "$CLIENT_ROOT"
cd "$CLIENT_ROOT"
p4 sync

# Changelist: initial checkin. Engine/Build/Build.version is required - UnrealGameSync's OpenProjectInfo walks up
# from the project file looking for exactly this path to identify the branch root.
mkdir -p Engine/Build TestProject/Source/TestProject TestProject/Config

cat > Engine/Build/Build.version << 'EOF'
{
	"MajorVersion": 5,
	"MinorVersion": 6,
	"PatchVersion": 0,
	"Changelist": 0,
	"CompatibleChangelist": 0,
	"IsLicenseeVersion": 0,
	"IsPromotedBuild": 1,
	"BranchName": "UGSTest-Main"
}
EOF

cat > TestProject/TestProject.uproject << 'EOF'
{
	"FileVersion": 3,
	"EngineAssociation": "5.6",
	"Category": "",
	"Modules": [
		{
			"Name": "TestProject",
			"Type": "Runtime",
			"LoadingPhase": "Default"
		}
	]
}
EOF

cat > TestProject/Source/TestProject/TestProject.Build.cs << 'EOF'
using UnrealBuildTool;

public class TestProject : ModuleRules
{
	public TestProject(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore" });
	}
}
EOF

cat > TestProject/Config/DefaultEngine.ini << 'EOF'
[/Script/EngineSettings.GeneralProjectSettings]
ProjectID=00000000000000000000000000000000
EOF

p4 add Engine/Build/Build.version TestProject/TestProject.uproject TestProject/Source/TestProject/TestProject.Build.cs TestProject/Config/DefaultEngine.ini
p4 submit -d "Initial checkin of Engine and TestProject"

# Changelist: tweak a config value
p4 edit TestProject/Config/DefaultEngine.ini
echo "bSmoothFrameRate=True" >> TestProject/Config/DefaultEngine.ini
p4 submit -d "Enable smooth framerate"

# Changelist: add a gameplay source file
cat > TestProject/Source/TestProject/TestProjectCharacter.cpp << 'EOF'
// Placeholder character implementation
EOF
p4 add TestProject/Source/TestProject/TestProjectCharacter.cpp
p4 submit -d "Add TestProjectCharacter"

# Changelist: a follow-up edit, so the changes list has some depth
p4 edit TestProject/Source/TestProject/TestProject.Build.cs
echo "// Fixed unused include warning" >> TestProject/Source/TestProject/TestProject.Build.cs
p4 submit -d "Fix build warning in TestProject.Build.cs"

# Stop the server cleanly before the Docker layer is captured
p4 admin stop
wait || true
