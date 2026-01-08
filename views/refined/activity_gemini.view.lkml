include: "activity.view"

# API reference for gemini logs in BigQuery:
# https://developers.google.com/workspace/admin/reports/v1/appendix/activity/gemini-in-workspace-apps
view: gemini {
  extends: [activity]

  # --- DRILL DOWN SET DEFINITION ---
  # This defines the columns shown when clicking on a chart
  set: drill_details {
    fields: [
      activity.email,
      activity.activity_date,
      activity.org_unit_name,
      activity.event_name,
      app_name,
      action
    ]
  }

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

  parameter: time_granularity {
    view_label: "Gemini"
    label: "Time Granularity"
    description: "Select the time grouping for trend charts (Daily, Weekly, Monthly)."
    hidden: no
    type: unquoted
    default_value: "week"
    allowed_value: { label: "Daily Trend" value: "day" }
    allowed_value: { label: "Weekly Trend" value: "week" }
    allowed_value: { label: "Monthly Trend" value: "month" }
  }

  dimension: dynamic_activity_date {
    view_label: "Gemini"
    label_from_parameter: time_granularity
    description: "Changes the date granularity based on the 'Time Granularity' parameter."
    hidden: no
    sql:
    {% if time_granularity._parameter_value == 'month' %}
      ${activity_month}
    {% elsif time_granularity._parameter_value == 'week' %}
      ${activity_week}
    {% else %}
      ${activity_date}
    {% endif %} ;;
  }

  dimension: app_name {
    view_label: "Gemini"
    label: "App Name"
    description: "The Google Workspace application where the Gemini activity occurred (e.g., Docs, Sheets, Meet)."
    hidden: no
    type: string
    sql: ${TABLE}.gemini_for_workspace.app_name ;;
    drill_fields: [activity_gemini_users*]
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
    description: "Categorizes the type of generative AI action event, such as 'active_generate' for direct user interactions or 'inactive' which represents a category where the user is not considered to be actively engaging with Gemini."
    type: string
    sql: ${TABLE}.gemini_for_workspace.event_category ;;
  }

  dimension: event_category_split {
    view_label: "Gemini"
    label: "Event Category"
    description: "Summarized event category existing dimension in 2 active and inactive"
    hidden: no
    type: string
    case: {
      when: {
        sql: CONTAINS_SUBSTR(${event_category}, "active_");;
        label: "Active"
      }
      else: "Passive"
    }
  }

  dimension: action_category {
    view_label: "Gemini"
    label: "Action Category"
    description: "Clusters raw Gemini actions into high-level business categories (Creation, Summarization, Refinement, etc.)"
    hidden: no
    type: string
    case: {
      when: {
        sql: ${action} IN ('generate_document', 'generate_text', 'generate_text_completion') ;;
        label: "Content Creation"
      }
      when: {
        sql: ${action} IN ('summarize', 'summarize_homepage', 'summarize_proactive', 'summarize_proactive_short') ;;
        label: "Summarization"
      }
      when: {
        sql: ${action} IN ('elaborate', 'formalize', 'proofread', 'auto_proofread') ;;
        label: "Refinement & Editing"
      }
      when: {
        sql: ${action} IN ('conversation', 'classic_use_case_gemini_app', 'search_web', 'classic_use_case_meet_studio_look') ;;
        label: "Interaction & Research"
      }
      when: {
        sql: ${action} IN ('generate_starter_tile_prompts', 'generate_nudge_prompts', 'proactive_suggestions', 'generate_apps_search_overlay_suggestions', 'detect_schedule_intent_compose', 'evaluate_natural_language_condition') ;;
        label: "Assistance & Discovery"
      }
      else: "Other"
    }
    drill_fields: [action, app_name]
  }

  measure: count_apps {
    hidden: no
    label: " Distinct Apps"
    view_label: "Gemini"
    description: "Count of all activity apps"
    type: count_distinct
    allow_approximate_optimization: yes
    sql: ${app_name} ;;
    drill_fields: [drill_details*]
  }

  measure: count_actions {
    hidden: no
    label: "Unique actions"
    view_label: "Gemini"
    description: "Distinct number of Actions"
    type: count_distinct
    allow_approximate_optimization: yes
    sql: ${action} ;;
    drill_fields: [drill_details*]
  }

  measure: count_opportunity_gap {
    view_label: "Gemini Adoption"
    label: "Non-Gemini Users (Gap)"
    description: "Active Workspace users who have NOT used Gemini in this period."
    hidden: no
    type: number
    # Logic: Total Workspace Users (Sidecar) - Active Gemini Users (This View)
    sql: ${workspace_benchmark_sidecar.count_core_users} - ${count_user} ;;
    link: {
      label: "View Opportunity Emails"
      url: "/explore/workspace_audit_logs/activity_consolidated?fields=activity.email,activity.active_user_org_unit_name,activity.count&f[activity.record_type]=drive,gmail,docs,sheets,slides,meet,calendar&f[activity.active_user_org_unit_name]={{ workspace_benchmark_sidecar.ou_name._value | url_encode }}&f[activity.activity_date]={{ _filters['activity.activity_date'] | url_encode }}&sorts=activity.count+desc&limit=500"
    }
  }

  measure: real_penetration_rate {
    view_label: "Gemini Adoption"
    label: "Real Penetration Rate %"
    description: "Percentage of Active Workspace Users who are using Gemini."
    hidden: no
    type: number
    sql: 1.0 * ${count_user} / NULLIF(${workspace_benchmark_sidecar.count_core_users}, 0) ;;
    value_format_name: percent_1
  }

  measure: count {
    drill_fields: [drill_details*]
  }

  measure: count_user {
    label: "Active Gemini Users"
    type: count_distinct
    sql: ${email} ;;
    drill_fields: [drill_details*]
  }

  # --- POP PERIOD OVER PERIOD LOGIC ---

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

  filter: date_filter {
    hidden: no
    view_label: "_PoP"
    description: "Use this date filter in combination with the timeframes dimension for dynamic date filtering"
    type: date
  }

  dimension_group: filter_start_date {
    hidden: yes
    type: time
    timeframes: [raw,date]
    sql: CASE WHEN {% date_start date_filter %} IS NULL THEN '2013-01-01' ELSE CAST({% date_start date_filter %} AS DATE) END;;
  }

  dimension_group: filter_end_date {
    hidden: yes
    type: time
    timeframes: [raw,date]
    sql: CASE WHEN {% date_end date_filter %} IS NULL THEN CURRENT_DATE ELSE CAST({% date_end date_filter %} AS DATE) END;;
  }

  dimension: interval {
    hidden: yes
    type: number
    sql: DATE_DIFF(${filter_end_date_raw}, ${filter_start_date_raw}, DAY) ;;
  }

  dimension: previous_start_date {
    hidden: yes
    type: string
    sql: DATE_ADD(${filter_start_date_raw}, INTERVAL- ${interval} DAY);;
  }

  dimension: timeframes {
    view_label: "_PoP"
    hidden: no
    type: string
    case: {
      when: {
        sql: ${is_current_period} = true;;
        label: "Selected Period"
      }
      when: {
        sql: ${is_previous_period} = true;;
        label: "Previous Period"
      }
      else: "Not in time period"
    }
  }

  dimension: is_current_period {
    type: yesno
    sql: ${activity_date} >= ${filter_start_date_date} AND ${activity_date} < ${filter_end_date_date} ;;
  }

  dimension: is_previous_period {
    type: yesno
    sql: ${activity_date} >= ${previous_start_date} AND ${activity_date} < ${filter_start_date_date} ;;
  }

  measure: selected_period_count_events {
    hidden: no
    view_label: "_PoP"
    type: count
    filters: [is_current_period: "yes"]
    value_format_name: decimal_0
  }
  measure: previous_period_count_events {
    hidden: no
    view_label: "_PoP"
    type: count
    filters: [is_previous_period: "yes"]
    value_format_name: decimal_0
  }

  measure: selected_period_count_users {
    hidden: no
    view_label: "_PoP"
    type: count_distinct
    sql: ${email} ;;
    filters: [is_current_period: "yes"]
    value_format_name: decimal_0
  }
  measure: previous_period_count_users {
    hidden: no
    view_label: "_PoP"
    type: count_distinct
    sql: ${email} ;;
    filters: [is_previous_period: "yes"]
    value_format_name: decimal_0
  }

  dimension: ytd_only {hidden:yes}
  dimension: mtd_only {hidden:yes}
  dimension: wtd_only {hidden:yes}
}

# --- INTERNAL SIDECAR VIEW ---
# Kept in the same file as per your original structure
view: workspace_benchmark_sidecar {
  derived_table: {
    sql:
      SELECT
        ou_lookup.ou_name,
        COUNT(DISTINCT activity.email) as active_core_users
      FROM `@{WORKSPACE_ANALYTICS_PROJECT_ID}.@{WORKSPACE_ANALYTICS_DATASET_NAME}.activity` AS activity
      LEFT JOIN ${ou_user_lookup.SQL_TABLE_NAME} AS ou_lookup
        ON activity.email = ou_lookup.email
      WHERE
        activity.record_type IN ('drive', 'gmail', 'docs', 'sheets', 'slides', 'meet', 'calendar')
        AND activity.record_type != 'gemini_for_workspace'
        AND {% condition activity.activity_date %} TIMESTAMP_MICROS(activity.time_usec) {% endcondition %}
      GROUP BY 1
    ;;
  }

  dimension: ou_name {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.ou_name ;;
  }

  measure: count_core_users {
    view_label: "Gemini Adoption"
    label: "Total Active Workspace Users"
    description: "Distinct users active in Core Apps (Docs, Drive, Gmail, etc.) in the selected period."
    hidden: no
    type: sum
    sql: ${TABLE}.active_core_users ;;
    link: {
      label: "View User List (Core Workspace)"
      url: "/explore/workspace_audit_logs/activity?fields=activity.email,activity.count&f[activity.record_type]=drive,gmail,docs,sheets,slides,meet,calendar&f[activity.active_user_org_unit_name]={{ ou_name._value | url_encode }}&f[activity.activity_date]={{ _filters['activity.activity_date'] | url_encode }}"
    }
  }
}

view: gemini_app_penetration {
  derived_table: {
    sql:
      WITH universe_counts AS (
        SELECT
          -- Dynamic SQL: Prepares data to match the chosen dimension
          {% if analysis_grain._parameter_value == 'total' %}
             NULL as activity_date,
          {% else %}
             DATE_TRUNC(DATE(TIMESTAMP_MICROS(activity.time_usec)), {% parameter analysis_grain %}) AS activity_date,
          {% endif %}

          activity.record_type AS app_name,
          COUNT(DISTINCT activity.email) AS total_users
        FROM `@{WORKSPACE_ANALYTICS_PROJECT_ID}.@{WORKSPACE_ANALYTICS_DATASET_NAME}.activity` AS activity
        INNER JOIN ${ou_user_lookup.SQL_TABLE_NAME} AS ou_lookup
          ON ou_lookup.json_ou_path = TO_JSON_STRING(activity.org_unit_name_path)
        WHERE
          activity.record_type IN ('chat', 'drive', 'gmail', 'meet')
          AND {% condition date_filter %} TIMESTAMP_MICROS(activity.time_usec) {% endcondition %}
          AND {% condition ou_filter %} ou_lookup.ou_id {% endcondition %}
        GROUP BY 1, 2
      ),
      gemini_counts AS (
        SELECT
          {% if analysis_grain._parameter_value == 'total' %}
             NULL as activity_date,
          {% else %}
             DATE_TRUNC(DATE(TIMESTAMP_MICROS(activity.time_usec)), {% parameter analysis_grain %}) AS activity_date,
          {% endif %}

          activity.gemini_for_workspace.app_name AS app_name,
          COUNT(DISTINCT activity.email) AS ai_users
        FROM `@{WORKSPACE_ANALYTICS_PROJECT_ID}.@{WORKSPACE_ANALYTICS_DATASET_NAME}.activity` AS activity
        INNER JOIN ${ou_user_lookup.SQL_TABLE_NAME} AS ou_lookup
          ON ou_lookup.json_ou_path = TO_JSON_STRING(activity.org_unit_name_path)
        WHERE
          activity.record_type = 'gemini_for_workspace'
          AND activity.gemini_for_workspace.app_name IN ('chat', 'drive', 'gmail', 'meet')
          AND {% condition date_filter %} TIMESTAMP_MICROS(activity.time_usec) {% endcondition %}
          AND {% condition ou_filter %} ou_lookup.ou_id {% endcondition %}
        GROUP BY 1, 2
      )
      SELECT
        universe.activity_date,
        universe.app_name,
        COALESCE(universe.total_users, 0) AS universe_count,
        COALESCE(gemini.ai_users, 0) AS gemini_count
      FROM universe_counts AS universe
      LEFT JOIN gemini_counts AS gemini
        ON universe.app_name = gemini.app_name
        AND (universe.activity_date = gemini.activity_date OR universe.activity_date IS NULL)
    ;;
  }

# Filters & Parameters ---
  filter: date_filter {
    type: date
    label: "Date Filter"
  }

  filter: ou_filter {
    type: string
    label: "OU Filter (ID)"
    suggest_explore: gemini
    suggest_dimension: ou_user_lookup.ou_id
  }

  parameter: analysis_grain {
    type: unquoted
    label: "Analysis Granularity"
    description: "Choose 'Total Period' for summary or a Trend option for time series."
    default_value: "week"

    # Values match BigQuery DATE_TRUNC keywords
    allowed_value: { label: "" value: "total" }
    allowed_value: { label: "Daily Trend" value: "day" }
    allowed_value: { label: "Weekly Trend" value: "week" }
    allowed_value: { label: "Monthly Trend" value: "month" }
  }

  # DIMENSIONS ---

  # Raw dimension from SQL
  dimension: activity_raw {
    hidden: yes
    type: date
    sql: ${TABLE}.activity_date ;;
  }

  dimension: activity_day {
    hidden: yes
    type: date
    sql: ${TABLE}.activity_date ;;
  }

  dimension: activity_week {
    hidden: yes
    type: date_week
    sql: ${TABLE}.activity_date ;;
  }

  dimension: activity_month {
    hidden: yes
    type: date_month
    sql: ${TABLE}.activity_date ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}.app_name ;;
    label: "Application"
  }


  dimension: dynamic_date {
    label_from_parameter: analysis_grain

    # We inject the correct dimension using Liquid
    sql:
    {% if analysis_grain._parameter_value == 'month' %}
      ${activity_month}
    {% elsif analysis_grain._parameter_value == 'week' %}
      ${activity_week}
    {% elsif analysis_grain._parameter_value == 'day' %}
      ${activity_day}
    {% else %}
      'Total Period'
    {% endif %} ;;
  }

  # PK
  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(COALESCE(CAST(${activity_raw} AS STRING), 'TOT'), ${app_name}) ;;
  }


  measure: total_users {
    type: sum
    sql: ${TABLE}.universe_count ;;
    label: "Total App Users"
    link: {
      label: "Drill Down Users"
      url: "
      {% if analysis_grain._parameter_value == 'total' %}
      /explore/workspace_audit_logs/gemini?fields=activity.email,activity.count&f[activity.record_type]={{ app_name._value }}&f[activity.activity_date]={{ _filters['date_filter'] | url_encode }}
      {% else %}
      /explore/workspace_audit_logs/gemini?fields=activity.email,activity.count&f[activity.record_type]={{ app_name._value }}&f[activity.activity_date]={{ dynamic_date._value }}
      {% endif %}
      "
    }
  }

  measure: gemini_users {
    type: sum
    sql: ${TABLE}.gemini_count ;;
    label: "Gemini Active Users"
    link: {
      label: "Drill Down AI Users"
      url: "
      {% if analysis_grain._parameter_value == 'total' %}
      /explore/workspace_audit_logs/gemini?fields=activity.email,gemini.count_actions&f[activity.record_type]=gemini_for_workspace&f[gemini.app_name]={{ app_name._value }}&f[activity.activity_date]={{ _filters['date_filter'] | url_encode }}
      {% else %}
      /explore/workspace_audit_logs/gemini?fields=activity.email,gemini.count_actions&f[activity.record_type]=gemini_for_workspace&f[gemini.app_name]={{ app_name._value }}&f[activity.activity_date]={{ dynamic_date._value }}
      {% endif %}
      "
    }
  }

  measure: penetration_rate {
    type: number
    sql: 1.0 * ${gemini_users} / NULLIF(${total_users}, 0) ;;
    label: "% Penetration"
    value_format_name: percent_1
  }
}
