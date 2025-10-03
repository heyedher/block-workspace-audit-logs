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

constant: DAILY_VIZ_CONFIG {
  value: "{% assign vis_config = '{
    \"x_axis_gridlines\": false,
    \"y_axis_gridlines\": true,
    \"show_view_names\": false,
    \"show_y_axis_labels\": true,
    \"show_y_axis_ticks\": true,
    \"y_axis_tick_density\": \"default\",
    \"y_axis_tick_density_custom\": 5,
    \"show_x_axis_label\": true,
    \"show_x_axis_ticks\": true,
    \"y_axis_scale_mode\": \"linear\",
    \"x_axis_reversed\": false,
    \"y_axis_reversed\": false,
    \"plot_size_by_field\": false,
    \"trellis\": \"\",
    \"stacking\": \"normal\",
    \"limit_displayed_rows\": false,
    \"legend_position\": \"center\",
    \"point_style\": \"none\",
    \"show_value_labels\": false,
    \"label_density\": 25,
    \"x_axis_scale\": \"auto\",
    \"y_axis_combined\": true,
    \"ordering\": \"none\",
    \"show_null_labels\": false,
    \"show_totals_labels\": false,
    \"show_silhouette\": false,
    \"totals_color\": \"#808080\",
    \"color_application\": {
        \"collection_id\": \"7c56cc21-66e4-41c9-81ce-a60e1c3967b2\",
        \"palette_id\": \"5d189dfc-4f46-46f3-822b-bfb0b61777b1\",
        \"options\": {
            \"steps\": 5
        }
    },
    \"y_axes\": [
        {
            \"label\": \"Count\",
            \"orientation\": \"left\",
            \"series\": [
                {
                    \"axisId\": \"activity.dynamic_users_events\",
                    \"id\": \"activity.dynamic_users_events\",
                    \"name\": \"Users\n    \"
                }
            ],
            \"showLabels\": true,
            \"showValues\": true,
            \"unpinAxis\": false,
            \"tickDensity\": \"default\",
            \"tickDensityCustom\": 5,
            \"type\": \"linear\"
        }
    ],
    \"x_axis_label\": \"Hour of the day\",
    \"x_axis_zoom\": true,
    \"y_axis_zoom\": true,
    \"hide_legend\": false,
    \"series_types\": {},
    \"series_colors\": {
        \"activity.dynamic_users_events\": \"#7CB342\",
        \"slides - activity.dynamic_users_events\": \"#7CB342\"
    },
    \"column_group_spacing_ratio\": 0.2,
    \"type\": \"looker_column\",
    \"defaults_version\": 1,
    \"hidden_pivots\": {},
    \"show_row_numbers\": true,
    \"transpose\": false,
    \"truncate_text\": true,
    \"hide_totals\": false,
    \"hide_row_totals\": false,
    \"size_to_fit\": true,
    \"table_theme\": \"white\",
    \"enable_conditional_formatting\": false,
    \"header_text_alignment\": \"left\",
    \"header_font_size\": 12,
    \"rows_font_size\": 12,
    \"conditional_formatting_include_totals\": false,
    \"conditional_formatting_include_nulls\": false
}' %}"
}
