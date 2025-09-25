include: "activity.view"

# API reference for drive logs in BigQuery:
# https://developers.google.com/admin-sdk/reports/v1/appendix/activity/drive
view: gemini {
  extends: [activity]

  parameter: dynamic_metric {
    view_label: "Gemini"
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
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.app_name ;;
  }

  dimension: feature_source {
    view_label: "Gemini"
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.feature_source ;;
  }

  dimension: action {
    view_label: "Gemini"
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.action ;;
  }

  dimension: event_category {
    view_label: "Gemini"
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.event_category ;;
  }

  dimension: gemini_for_workspace {
    view_label: "Gemini"
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace ;;
  }

  dimension: network_info {
    view_label: "Gemini"
    hidden: no
    type: string
    sql: ${TABLE}.network_info ;;
  }

  measure: dynamic_users_events {
    view_label: "Gemini"
    type: number
    label: "{% if dynamic_metric._parameter_value == 'users' %}Users
    {% elsif dynamic_metric._parameter_value == 'events' %}Events
    {% else %}Events{% endif %}"

    sql:
      {% if dynamic_metric._parameter_value == "users" %} ${count_user}
      {% elsif dynamic_metric._parameter_value == "events" %} ${count}
      {% else %} ${count} {% endif %} ;;
    hidden: no
  }

  # overwrite default drill for all measures
  drill_fields: [activity_drive*]
}
