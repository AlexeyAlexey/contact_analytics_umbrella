defmodule ContactAnalytics.CustomAttrs.ChangesetConv do

  # def attr_changeset(schema, params) do
  #   # params = struct(schema, params) |> Map.from_struct()
  #   params = Map.merge(params, %{in_at: nil, up_at: nil}, fn _k, v1, _v2 -> v1 end)

  #   schema
  #   |> cast(params, [:id, :v, :in_at, :up_at])
  #   |> validate_required([:id, :v, :in_at, :up_at])
  # end

  # @spec to_map(%{attr_string: %Ecto.Changeset{changes: map},
  #                attr_bigint: %Ecto.Changeset{changes: map},
  #                attr_float: %Ecto.Changeset{changes: map},
  #                attr_decimal: %Ecto.Changeset{changes: map},
  #                attr_utc_datetime: %Ecto.Changeset{changes: map}}, []) :: %{attr_string: list,
  #                                                                            attr_bigint: list,
  #                                                                            attr_float: list,
  #                                                                            attr_decimal: list,
  #                                                                            attr_utc_datetime: list}
  def to_map(attrs, acc \\ [])

  def to_map(%{attr_string: [ %Ecto.Changeset{changes: changes} | rest]} = attrs, acc) do
    to_map(Map.put(attrs, :attr_string, rest), [changes | acc])
  end
  def to_map(%{attr_string: []} = attrs, acc) do
    to_map(Map.merge(attrs, %{attr_string: acc}), [])
  end

  def to_map(%{attr_bigint: [ %Ecto.Changeset{changes: changes} | rest]} = attrs, acc) do
    to_map(Map.put(attrs, :attr_bigint, rest), [changes | acc])
  end
  def to_map(%{attr_bigint: []} = attrs, acc) do
    to_map(Map.merge(attrs, %{attr_bigint: acc}), [])
  end

  def to_map(%{attr_float: [ %Ecto.Changeset{changes: changes} | rest]} = attrs, acc) do
    to_map(Map.put(attrs, :attr_float, rest), [changes | acc])
  end
  def to_map(%{attr_float: []} = attrs, acc) do
    to_map(Map.merge(attrs, %{attr_float: acc}), [])
  end

  def to_map(%{attr_decimal: [ %Ecto.Changeset{changes: changes} | rest]} = attrs, acc) do
    to_map(Map.put(attrs, :attr_decimal, rest), [changes | acc])
  end
  def to_map(%{attr_decimal: []} = attrs, acc) do
    to_map(Map.merge(attrs, %{attr_decimal: acc}), [])
  end

  def to_map(%{attr_utc_datetime: [ %Ecto.Changeset{changes: changes} | rest]} = attrs, acc) do
    to_map(Map.put(attrs, :attr_utc_datetime, rest), [changes | acc])
  end
  def to_map(%{attr_utc_datetime: []} = attrs, acc) do
    to_map(Map.merge(attrs, %{attr_utc_datetime: acc}), [])
  end

  def to_map(attrs, _acc) do
    attrs
  end

end
