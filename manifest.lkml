constant: WORKSPACE_ANALYTICS_CONNECTION_NAME {
  value: "default_bigquery_connection"
  export: override_required
}

constant: WORKSPACE_ANALYTICS_PROJECT_ID {
  value: "cymbal-roadmap-bq-logs"
  export: override_required
}

constant: WORKSPACE_ANALYTICS_DATASET_NAME {
  value: "roadmap_cymbal_dev"
  export: override_required
}

constant: WORKSPACE_ANALYTICS_PRIMARY_DOMAIN {
  value: "roadmap.cymbal.dev"
  export: override_required
}

constant: WORKSPACE_ANALYTICS_SECONDARY_DOMAINS {
  value: "ca.gcpdemos.com,child.eskudemo1.gcpdemos.com,eskudemo1.gcpdemos.com,eskudemo1gcpdemos.onmicrosoft.com,newfoo.eskudemo1.gcpdemos.com,o365.eskudemo1.gcpdemos.com,test.roadmap.cymbal.dev,test1.eskudemo1.gcpdemos.com,eskudemo1.gcpdemos.com"
  export: override_required
}
