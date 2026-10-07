# Problem Statement 1 - Size Check Pre-Sync

Users can find themselves in an awkward position where they have a partial sync completed due to their workspace storage running out mid-sync
This can be challenging for people who may be less familiar with the underlying Perforce system, and primarily interface with UGS. 

When they perform their sync, and the storage runs out, their workspace may need a more guided hand to resolve potential workspace inconsistencies, as a result of the partial sync

To alleviate this issue, we are able to check the expected size that a sync might be, and compare it against the user's remaining local storage
This can help those who may not be as familiar to ensure they have enough storage before syncing occurs. Thus eliminating the concern entirely of needing to resolve their partially synced workspace.


# Problem Statement 2 - Shared DDC Connectivity
For most non-technical users it may not be clear when things are configured incorrectly. The Shared DDC is a great way to get people working quickly, however if its not setup correctly,
users can carry on without noticing, they may just think the system is slow, and let the shaders compile manually. This seems like a common issue for people to run into, and prototyping the functionality
seemed sensible, and fits well within the time constraints allotted. 

When users first launch the editor if the Shared DDC doesnt get utilised then users may spend a long time waiting. This is easy to ignore, as people often accept that "This is just the way it is" but is a huge slow down.
It is also something that the Shared DDC alleviates, if/when it is configured correctly. This is something we can address via tooling, by ensuring its configured, and available for them. With no ambiguity!
