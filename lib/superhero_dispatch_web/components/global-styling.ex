defmodule SuperheroDispatchWeb.GlobalStyling do
  use Phoenix.Component

  # Priority styles
  def priority_class(:critical), do: "bg-red-100 text-red-800"
  def priority_class(:high), do: "bg-orange-100 text-orange-800"
  def priority_class(:medium), do: "bg-yellow-100 text-yellow-800"
  def priority_class(:low), do: "bg-green-100 text-green-800"

  # Incident status styles
  def status_class(:reported), do: "bg-blue-100 text-blue-800"
  def status_class(:dispatched), do: "bg-purple-100 text-purple-800"
  def status_class(:in_progress), do: "bg-amber-100 text-amber-800"
  def status_class(:resolved), do: "bg-green-100 text-green-800"
  def status_class(:closed), do: "bg-gray-100 text-gray-800"

  # Hero status styles
  def hero_status_class(:available), do: "bg-green-100 text-green-800"
  def hero_status_class(:dispatched), do: "bg-blue-100 text-blue-800"
  def hero_status_class(:on_scene), do: "bg-orange-100 text-orange-800"
  def hero_status_class(:off_duty), do: "bg-gray-100 text-gray-800"

  # Assignment status styles
  defp assignment_status_class(:assigned), do: "bg-blue-100 text-blue-800"
  defp assignment_status_class(:en_route), do: "bg-purple-100 text-purple-800"
  defp assignment_status_class(:on_scene), do: "bg-orange-100 text-orange-800"
  defp assignment_status_class(:completed), do: "bg-green-100 text-green-800"
end
