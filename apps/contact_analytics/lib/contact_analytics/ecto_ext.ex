defmodule EctoExt do
  defmodule DataType do
    defmodule BSONObjectId do
      use Ecto.Type
      def type, do: :map

      # Provide custom casting rules.
      # Cast strings into the struct to be used at runtime
      def cast(bson) when is_binary(bson) do
        BSON.ObjectId.decode(bson)
      end

      # Accept casting of structs as well
      def cast(%BSON.ObjectId{} = bson), do: {:ok, bson}

      # Everything else is a failure though
      def cast(_), do: :error

      # When loading data from the database, as long as it's a map,
      # we just put the data back into a struct to be stored in
      # the loaded schema struct.
      def load(data) when is_map(data) do
        data =
          for {key, val} <- data do
            {String.to_existing_atom(key), val}
          end
        {:ok, struct!(BSON.ObjectId, data)}
      end

      # When dumping data to the database, we *expect* a struct
      # but any value could be inserted into the schema struct at runtime,
      # so we need to guard against them.
      def dump(%BSON.ObjectId{} = bson), do: {:ok, Map.from_struct(bson)}
      def dump(_), do: :error
    end

    defmodule DateTimeDefault do
      use Ecto.ParameterizedType

      def type(_params), do: :date_time

      def init(opts) do
        Enum.into(opts, %{})
      end

      def cast(data, params) do
        case data do
          nil -> {:ok, params[:func].()}
          ""  -> {:ok, params[:func].()}
          _   -> {:ok, data}
        end
        
      end

      def dump(data, _dumper, _params) do
        {:ok, data}
      end
    end

    defmodule InList do
      use Ecto.ParameterizedType

      def type(_params), do: :string

      def init(opts) do
        Enum.into(opts, %{})
      end

      def cast(data, params) do
        if data in params[:in] do
          {:ok, data}
        else
          :error
        end
      end

      def dump(data, _dumper, _params) do
        {:ok, data}
      end
    end
  end
end
