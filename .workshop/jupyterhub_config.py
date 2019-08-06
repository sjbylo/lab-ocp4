resource_budget_mapping['custom'] = {
    "resource-limits" : {
        "kind": "LimitRange",
        "apiVersion": "v1",
        "metadata": {
            "name": "resource-limits",
            "annotations": {
                "resource-budget": "large"
            }
        },
        "spec": {
            "limits": [
                {
                    "type": "Pod",
                    "min": {
                        "cpu": "50m",
                        "memory": "32Mi"
                    },
                    "max": {
                        "cpu": "1",
                        "memory": "1Gi"
                    }
                },
                {
                    "type": "Container",
                    "min": {
                        "cpu": "50m",
                        "memory": "32Mi"
                    },
                    "max": {
                        "cpu": "1",
                        "memory": "1Gi"
                    },
                    "default": {
                        "cpu": "256m",
                        "memory": "768Mi"
                    },
                    "defaultRequest": {
                        "cpu": "50m",
                        "memory": "128Mi"
                    }
                },
                {
                    "type": "PersistentVolumeClaim",
                    "min": {
                        "storage": "1Gi"
                    },
                    "max": {
                        "storage": "10Gi"
                    }
                }
            ]
        }
    },
    "compute-resources" : {
        "kind": "ResourceQuota",
        "apiVersion": "v1",
        "metadata": {
            "name": "compute-resources",
            "annotations": {
                "resource-budget": "large"
            }
        },
        "spec": {
            "hard": {
                "limits.cpu": "2",
                "limits.memory": "6Gi"
            },
            "scopes": [
                "NotTerminating"
            ]
        }
    },
    "compute-resources-timebound" : {
        "kind": "ResourceQuota",
        "apiVersion": "v1",
        "metadata": {
            "name": "compute-resources-timebound",
            "annotations": {
                "resource-budget": "large"
            }
        },
        "spec": {
            "hard": {
                "limits.cpu": "2",
                "limits.memory": "6Gi"
            },
            "scopes": [
                "Terminating"
            ]
        }
    },
    "object-counts" : {
        "kind": "ResourceQuota",
        "apiVersion": "v1",
        "metadata": {
            "name": "object-counts",
            "annotations": {
                "resource-budget": "large"
            }
        },
        "spec": {
            "hard": {
                "persistentvolumeclaims": "12",
                "replicationcontrollers": "25",
                "secrets": "35",
                "services": "20"
            }
        }
    }
}
