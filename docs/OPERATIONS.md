# 🛠️ Operational Guide (Day 2 Operations)
***

## 1. 🏥 Health and Status Check
Use the following commands to quickly verify the health of the Longhorn storage platform and the application.

| Component | Command | Expected Result |
| :--- | :--- | :--- |
| **Longhorn Controller** | `kubectl get nodes.longhorn.io -n longhorn-system` | All nodes should show `Ready: True`. |
| **Storage Class** | `kubectl get sc` | The `longhorn` StorageClass should be present. |
| **PostgreSQL Pods** | `kubectl get pods -l app=postgres -n app-data-layer` | All Pods should be `Running` and `Ready`. |
| **Application Volume** | `kubectl get volume -n longhorn-system` | The PostgreSQL volume should be attached to the current leader node. |

***

## 2. 🚨 Troubleshooting: Node Failure
If a worker node fails, Longhorn will automatically handle the volume migration and recovery.

### 2.1. Verify Failed Node
Identify the node that is unreachable:

```bash
kubectl get nodes
```
---
### 2.2. Verify Volume Detachment Check the status of the PostgreSQL Persistent Volume (PV):
---
```bash

kubectl get pv -l app=postgres
Note: The volume status should eventually change to 'Detached' on the failed node.
```
---
### 2.3. Observe Automatic Failover
Longhorn will automatically schedule the volume's replicas to a healthy node and attach the volume to the new PostgreSQL leader Pod.
---
## 3. 💾 Backup & Restore Operations
Longhorn provides built-in backup capabilities to external object storage (e.g., S3).

3.1. Creating a Snapshot
To create a local snapshot of the PostgreSQL volume:

Access the Longhorn UI (via kubectl port-forward).

Navigate to Volume -> Select the PostgreSQL PV -> Click Create Snapshot.

3.2. Backing up to External Storage
Once snapshots are created, they can be backed up to the configured S3 target:

In the Longhorn UI, navigate to the Snapshot list.

Select the snapshot and click Backup.

3.3. Restoring a Volume
To restore the PostgreSQL volume from a backup, the application must be scaled down temporarily.

### Scale Down Application (to detach the current volume):
---
```Bash

kubectl scale statefulset postgres --replicas=0 -n app-data-layer
```
---
## 4. Restore via UI: In the Longhorn UI, navigate to Backup -> Select the desired restore point -> Click Restore.
---
### Scale Up Application (to mount the restored volume):
---

```Bash
kubectl scale statefulset postgres --replicas=3 -n app-data-layer
```
