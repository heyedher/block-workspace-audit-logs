include: "activity_base.explore"
include: "/views/refined/activity_gemini.view"

include: "/views/pdt/ou_user_lookup.view"

explore: gemini {
  extends: [activity_base]
  from: gemini
  always_filter: { filters: [activity.record_type: "gemini_for_workspace"] }
}
