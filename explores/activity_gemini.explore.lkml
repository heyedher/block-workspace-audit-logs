include: "activity_base.explore"

include: "/views/pdt/activity_active_user_facts.view"
include: "/views/refined/activity_gemini.view"
include: "/views/pdt/ou_user_lookup.view"

explore: gemini {
  extends: [activity_base]
  from: gemini
  always_filter: { filters: [activity.record_type: "gemini_for_workspace"] }

  # Benchmark Join
  # Joins the total workspace population for the "Real Penetration Rate"
  join: workspace_benchmark_sidecar {
    sql_on: ${ou_user_lookup_for_active_user.ou_name} = ${workspace_benchmark_sidecar.ou_name} ;;
    relationship: many_to_one
    type: left_outer
  }
}

explore: gemini_app_penetration {
  label: "Gemini Adoption by App (Standalone)"
}
