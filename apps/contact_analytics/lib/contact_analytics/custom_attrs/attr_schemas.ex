defmodule ContactAnalytics.CustomAttrs.AttrSchemas do
  use Ecto.Schema

  alias EctoExt.DataType.{DateTimeDefault}

  defmodule AttrBigint do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :id, :integer
      field :v, :integer
      field :up_at, DateTimeDefault, func: &DateTime.utc_now/0
    end

    def validate(doc, _setts \\ %{}) do
      doc = Map.merge(doc, %{up_at: nil})

      case cast(%__MODULE__{}, doc, [:id, :v, :up_at]) do
        %Ecto.Changeset{valid?: true, changes: changes} ->
          {:ok, changes}
        %Ecto.Changeset{valid?: false, errors: errors}->
          {:error, errors}
      end
    end
  end

  defmodule AttrFloat do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :id, :integer
      field :v, :float
      field :up_at, DateTimeDefault, func: &DateTime.utc_now/0
    end

    def validate(doc, _setts \\ %{}) do
      doc = Map.merge(doc, %{up_at: nil})

      case cast(%__MODULE__{}, doc, [:id, :v, :up_at]) do
        %Ecto.Changeset{valid?: true, changes: changes} ->
          {:ok, changes}
        %Ecto.Changeset{valid?: false, errors: errors}->
          {:error, errors}
      end
    end
  end

  defmodule AttrDecimal do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :id, :integer
      field :v, :decimal
      field :up_at, DateTimeDefault, func: &DateTime.utc_now/0
    end

    def validate(doc, _setts \\ %{}) do
      doc = Map.merge(doc, %{up_at: nil})

      case cast(%__MODULE__{}, doc, [:id, :v, :up_at]) do
        %Ecto.Changeset{valid?: true, changes: changes} ->
          {:ok, changes}
        %Ecto.Changeset{valid?: false, errors: errors}->
          {:error, errors}
      end
    end
  end

  defmodule AttrString do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :id, :integer
      field :v, :string
      field :up_at, DateTimeDefault, func: &DateTime.utc_now/0
    end

    def validate(doc, _setts \\ %{}) do
      doc = Map.merge(doc, %{up_at: nil})

      case cast(%__MODULE__{}, doc, [:id, :v, :up_at]) do
        %Ecto.Changeset{valid?: true, changes: changes} ->
          {:ok, changes}
        %Ecto.Changeset{valid?: false, errors: errors}->
          {:error, errors}
      end
    end
  end

  defmodule AttrUtcDateTime do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :id, :integer
      field :v, :utc_datetime
      field :up_at, DateTimeDefault, func: &DateTime.utc_now/0
    end

    def validate(doc, _setts \\ %{}) do
      doc = Map.merge(doc, %{up_at: nil})

      case cast(%__MODULE__{}, doc, [:id, :v, :up_at]) do
        %Ecto.Changeset{valid?: true, changes: changes} ->
          {:ok, changes}
        %Ecto.Changeset{valid?: false, errors: errors}->
          {:error, errors}
      end
    end
  end

  def validate(doc, data_type, setts \\ %{}) do
    case data_type do
      "bigint" ->
        AttrBigint.validate(doc, setts)
      "decimal" ->
        AttrDecimal.validate(doc, setts)
      "float" -> 
        AttrFloat.validate(doc, setts)
      "string" ->
        AttrString.validate(doc, setts)
      "utc_datetime" ->
        AttrUtcDateTime.validate(doc, setts)
      _ ->
        {:error, [errors: [id: {"is invalid", [type: :integer, validation: :cast]}]]}
    end
  end
end
