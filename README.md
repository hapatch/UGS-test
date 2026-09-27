This repository is designed to be copied and pasted over a genuine Unreal Engine repository.

## Pre-Requisites
- Windows development environment
- Docker (For Testing, if you have an alternative P4 server/workspace to use, you can skip this)
- P4v installed
- Clone Unreal Engine (this was built and tested against tag `5.8.3-release` from the official Unreal Engine repository)
- Follow the instructions for Unreal Engine setup. So that you are able to compile their Programs/Tools
- Clone this repository into a separate folder
- Copy this repository over the Unreal Engine folder, it will only replace the UnrealGameSync Program

## Instructions
- Start a local P4 server by running `start.ps1` from inside `Engine/Source/Programs/UnrealGameSync/Setup` in a separate terminal.
  - Alternatively you can use your own Perforce server / workspace.
- Navigate to P4V
- Connect to `localhost:1666` as `test.user`
- Create a new workspace for `//UGSTest/Main`
- Sync to changelist 2 on `//UGSTest/Main`
- Start UnrealGameSync (UGS) from your IDE
- Connect your newly created workspace to UGS
- Use the uproject file: `//UGSTest/Main/TestProject/TestProject.uproject` inside UGS
- Navigate to Options -> Application Settings -> Perforce -> Advanced, and configure the "Minimum Disk Space Left GB" option
- The sync from CL 2 to CL 5 will only be a few bytes, so set Minimum Disk Space to something above your current remaining disk space (in my case, I had ~180GB available, so I set the minimum to 200GB)
- Sync to CL 5 from UnrealGameSync
- Observe the new popup.

## What I changed
An existing size check already covered a 100MB buffer. I co-opted that logic and added a configurable value per user, then set a sensible default (changing the unit from megabytes to gigabytes for ease of use).

This let me reuse UGS's existing sync logic to determine the size of a sync, rather than implementing bespoke `sync -N` logic.

I also made the buffer configurable via a new setting in the options menu, so each user can set their own minimum threshold. A developer-set default that's sensible for us isn't always sensible for everyone else's workflow.

Making this configurable also means we don't need to ship a new UnrealGameSync release every time a user wants to adjust the threshold.

## Trade-Offs
I made both warning dialogs skippable rather than blocking, for speed of testing. That's not ideal for the end-user experience: really only one case should be overridable. When a sync fits on disk but drops you below your buffer. The other case, where the sync genuinely won't fit, shouldn't let users bypass it.

I didn't mock connectivity for local testing, and I didn't validate the precompiled-binary flow, to keep the change focused. Mocking the Perforce connection would have required too wide a refactor for this scope.

I also co-opted the existing logic inside `EpicGames.Perforce.Fixture` for spinning up a local Perforce instance via Docker for testing for ease-of-use. This somewhat duplicates the functionality from the other project, this other project could be adapted, or vice versa, but I decided against it due to the scope.

## What I'd do differently next time
My test setup uses a local P4 server running in Docker; I'd rather not add that as a hard dependency for testing generally.

Given the number of P4 processes involved, I opted to skip mocking Perforce for now and instead built a local test environment other developers can reuse. That was simpler and faster for an iterative test loop, especially without a dedicated dev P4 server available.

With more time, I'd look at whether mocking the Perforce connection UGS maintains is viable, and I'd also test the precompiled-binary flow as content creators rely on that path, and it's currently untested with these changes.
