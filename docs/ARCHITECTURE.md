# 💾 High-Availability Data Platform Architecture

## 1. 🎯 Project Goal
The primary goal of this project is to implement a **Highly Available (HA)** and resilient data platform on Kubernetes for stateful workloads. This is achieved by decoupling the application (PostgreSQL) from the storage layer (Longhorn).

## 2. 🗺️ System Diagram & Flow


The system operates based on the following flow:
1.  **Orchestration:** Kustomize applies the manifests and manages the Longhorn Helm Chart dependency.
2.  **Storage Provisioning:** Longhorn is installed, creating the required `StorageClass`.
3.  **Application Deployment:** PostgreSQL is deployed via a `StatefulSet`, requesting persistent storage using the Longhorn `StorageClass`.
4.  **Data Resilience:** Longhorn ensures data durability by replicating the Persistent Volume (PV) across multiple worker nodes (replicas: 3). If a node fails, the PV is automatically detached and reattached to a healthy node, ensuring near-zero downtime for the data layer.

## 3. ⚙️ Core Technology Decisions

| Component | Rationale | Why this approach? |
| :--- | :--- | :--- |
| **Storage (Longhorn)** | Chosen as the **Cloud-Native Storage (CNS)** solution for its simplicity, lightweight footprint, and built-in features like volume snapshots, backup to S3, and synchronous replication (HA). | Provides true HA by enabling Volume Live Migration and automatic failover, essential for `StatefulSets`. |
| **Orchestration (Kustomize + HelmCharts)** | Utilizes Kustomize's `helmCharts` feature to manage the Longhorn dependency. | **GitOps Best Practice:** Avoids generating and committing large, auto-generated Helm manifests (`generated.yaml`), ensuring the repository only contains human-readable configuration files (`kustomization.yaml` and `values.yaml`). |
| **Application (PostgreSQL)** | Deployed via a `StatefulSet` to guarantee stable network identity and ordered scaling/deployment, crucial for a database cluster. | Ensures each replica has a unique, stable Persistent Volume Claim (PVC) backed by Longhorn. |

## 4. 🔗 Key Configuration Details

The following settings were critical for HA:
* **Longhorn Replicas:** Set to `3` in `k8s/longhorn-base/values.yaml` to ensure data redundancy across three different failure domains (nodes).
* **HA Configuration:** `replica-soft-anti-affinity` is enabled to prevent Longhorn from placing multiple data replicas on the same Kubernetes node, maximizing resilience.
