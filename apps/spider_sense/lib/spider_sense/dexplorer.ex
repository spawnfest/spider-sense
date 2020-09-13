defmodule SpiderSense.DExplorer do
  @moduledoc """
  Dependencies explorer uses `tracer` compilation flag to collect
  information about source code
  """

  alias SpiderSense.EventBus

  defmodule Tracer do
    defmodule Behaviour do
      @callback start(String.t(), atom()) :: any()
    end

    defmodule Impl do
      @behaviour Behaviour

      @impl true
      def start(path_to_mix_file, module_name) do
        Code.put_compiler_option(:tracers, [module_name])
        Code.put_compiler_option(:parser_options, columns: true)

        Path.dirname(path_to_mix_file)
        |> Path.join("**/*.ex")
        |> Path.wildcard()
        |> Kernel.ParallelCompiler.compile()

        Code.put_compiler_option(:tracers, [])
        Code.put_compiler_option(:parser_options, [])
      end
    end

    @behaviour Behaviour

    @impl true
    defdelegate start(path_to_mix_file, module_name), to: SpiderSense.Adapters.tracer()
  end

  @doc """
  Starts feeding the tracer with compilation events.
  To receive these messages you must call `&subscribe/0`
  It forcefully recompiles a mix project.
  """
  def start(path_to_mix_file) do
    dispatch(:explore_project_start, nil)
    Tracer.start(path_to_mix_file, __MODULE__)
    dispatch(:explore_project_end, nil)
  end

  def subscribe() do
    EventBus.subscribe(__MODULE__)
  end

  @doc "Elixir compiler callback implementation"
  def trace(compiler_event, env) do
    dispatch(compiler_event, env)
    :ok
  end

  defp dispatch(compiler_event, env) do
    EventBus.dispatch(__MODULE__, {:explorer, compiler_event, env})
  end

  def write_all_events(path_to_mix_file, path_to_events_file) do
    binary =
      stream_events(path_to_mix_file)
      |> Enum.into([])
      |> :erlang.term_to_binary()

    File.write!(path_to_events_file, binary)
  end

  def stream_events(path_to_mix_file, timeout \\ 1000) do
    Stream.resource(
      fn ->
        subscribe()
        start(path_to_mix_file)

        receive do
          {:explorer, :explore_project_start, _} -> nil
        after
          timeout -> raise "Fail to subscribe to explorer"
        end
      end,
      fn _ ->
        receive do
          {:explorer, :explore_project_end, _} -> {:halt, nil}
          {:explorer, _, _} = e -> {[e], nil}
        end
      end,
      fn _ ->
        nil
        # TODO: unsubscribe
      end
    )
  end
end
