include: "activity.view"

# API reference for gemini logs in BigQuery:
# https://developers.google.com/workspace/admin/reports/v1/appendix/activity/gemini-in-workspace-apps
view: gemini {
  extends: [activity]

  parameter: dynamic_metric {
    view_label: "Gemini"
    label: "Dynamic Metric"
    description: "Select whether to count the total number of unique users or the total number of events."
    type: unquoted
    hidden: no
    default_value: "events"
    allowed_value: {
      value: "users"
      label: "Users"
    }
    allowed_value: {
      value: "events"
      label: "Events"
    }
  }

  dimension_group: activity {
    timeframes: [
      raw,
      time,
      hour,
      date,
      day_of_week,
      week,
      month,
      quarter,
      year,
      hour_of_day
    ]
  }

  dimension: app_name {
    view_label: "Gemini"
    label: "App Name"
    description: "The Google Workspace application where the Gemini activity occurred (e.g., Docs, Sheets, Meet)."
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.app_name ;;
    drill_fields: [activity_gemini_users*]
    link: {
      label: "Daily Usage"
      url: "@{DAILY_VIZ_CONFIG}{{ link }}&fields=activity.activity_hour_of_day,activity.app_name,activity.count&pivots=activity.app_name&fill_fields=activity.activity_hour_of_daye&f[activity.feature_source]=-NULL&sorts=activity.app_name,activity.activity_hour_of_day&limit=500&column_limit=50&vis_config={{ vis_config | encode_uri }}"
    }
  }

  dimension: feature_source {
    view_label: "Gemini"
    label: "Feature Source"
    description: "The specific feature or UI element within the app that initiated the action (e.g., side_panel, chat_with_gemini)."
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.feature_source ;;

  }

  dimension: action {
    view_label: "Gemini"
    label: "Action"
    description: "The specific action performed by the user with Gemini (e.g., bulletize, catch_me_up)."
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.action ;;
  }

  dimension: event_category {
    view_label: "Gemini"
    label: "Event Category"
    description: "Categorizes the type of generative AI action event, such as 'active_generate' for direct user interactions or 'inactive' which represents a category where the user is not considered to be actively engaging with Gemini."
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.event_category ;;
  }

  measure: count_apps {
    hidden: no
    label: "Count of Apps"
    view_label: "Gemini"
    description: "Count of all activity apps"
    type: count_distinct
    allow_approximate_optimization: yes
    sql: ${app_name} ;;
    drill_fields: [activity_gemini_users*]
    link: {
      label: "By Apps"
      url: "{{ link }}&fields=activity.app_name,activity.count,activity.count_actions&f[activity.activity_date]=30+days&f[activity.json_ou_path]=&f[activity.record_type]=gemini_for_workspace&sorts=activity.count+desc&limit=500&column_limit=50&total=on"
    }
  }

  measure: count_actions {
    hidden: no
    label: "Count of Actions"
    view_label: "Gemini"
    description: "Distinct number of Actions"
    type: count_distinct
    allow_approximate_optimization: yes
    sql: ${action} ;;
  }

  measure: count {
    drill_fields: [activity_gemini_users*]
    link: {
      label: "By Apps"
      url: "{{ link }}&fields=activity.app_name,activity.count,activity.count_actions&f[activity.activity_date]=30+days&f[activity.json_ou_path]=&f[activity.record_type]=gemini_for_workspace&sorts=activity.count+desc&limit=500&column_limit=50&total=on"
    }
    link: {
      label: "By User"
      url: "{{ link }}&fields=activity.count,activity.count_actions,activity.email&f[activity.activity_date]=30+days&f[activity.json_ou_path]=&f[activity.record_type]=gemini_for_workspace&sorts=activity.count+desc&limit=500&column_limit=50&total=on&"
    }
    link: {
      label: "By Actions"
      url: "{{ link }}&fields=activity.action,activity.count,activity.count_actions&f[activity.activity_date]=30+days&f[activity.json_ou_path]=&f[activity.record_type]=gemini_for_workspace&sorts=activity.count+desc&limit=500&column_limit=50&total=on"
    }
    link: {
      label: "By Source"
      url: "{{ link }}&fields=activity.count,activity.count_actions,activity.feature_source&f[activity.activity_date]=30+days&f[activity.json_ou_path]=&f[activity.record_type]=gemini_for_workspace&sorts=activity.count+desc&limit=500&column_limit=50&total=on&"
    }
  }

  measure: count_user {
    drill_fields: [activity_gemini_users*]
  }

  measure: count_last_month {
    hidden: no
    view_label: "Gemini"
    label: "Count of Events Last Month"
    type: period_over_period
    based_on: count
    based_on_time: activity_date
    period: month
    kind: previous
  }

  measure: count_users_last_month {
    hidden: no
    view_label: "Gemini"
    label: "Count of Users Last Month"
    type: period_over_period
    based_on: count_user
    based_on_time: activity_date
    period: month
    kind: previous
  }

  measure: count_sources {
    hidden: no
    label: "Count of Source"
    view_label: "Gemini"
    description: "Distinct number of Sources"
    type: count_distinct
    allow_approximate_optimization: yes
    sql: ${feature_source} ;;
  }
}
