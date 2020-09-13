# Spider Sense

Spider Sense traverses a project's web of dependencies and displays them in the browser. The dependencies, modules and function calls are displayed using Phoenix LiveView and D3 which then can be filtered and explored.

# Application Structure

Spider Sense is structured as an umbrella application with two applications under the umbrella:

- [spider_sense](https://github.com/spawnfest/spider-sense/tree/master/apps/spider_sense) - compiles the code of a target application and traces modules called in that application
- [spider_sense_web](https://github.com/spawnfest/spider-sense/tree/master/apps/spider_sense_web) - a Phoenix web UI that displays traced modules as a graph

`spider_sense_web` depends on `spider_sense` to provide compiled module data to the web UI.

# Installing and Running

## Web UI

The web UI requires Elixir v1.10 and Phoenix v1.5 to be installed.
Follow instructions to install Phoenix [here](https://hexdocs.pm/phoenix/installation.html).
Spider Sense does not rely on a database, so an Ecto-compatiable database platform, such as PostgreSQL, does _not_ need to be installed.

Set the `apps/spider_sense_web` as your current working directory.

```
cd apps/spider_sense_web
```

Install the Hex dependencies for `spider_sense_web`:

```
mix deps.get
```

Install the Node.js dependencies used by the web UI:

```
npm install --prefix ./assets
```

This will also compile the `spider_sense` app.
Finally, run the server, which will start at http://localhost:4000

```
mix phx.server
```

# Usage

## Web UI

Navigate to http://localhost:4000.
When the UI is loaded, the result of compiling and tracing an [example application](https://github.com/spawnfest/spider-sense/tree/master/apps/spider_sense/priv/example) is shown as a graph.
Each node specifies a module in the application and a link between nodes means that one module calls the other.
The directions of these links is currently not displayed.
The graph can be zoomed by scrolling after clicking inside the graph, and it can be panned by clicking and dragging in empty space within the graph area.
Individual nodes can be dragged around the graph area to more easily view them.

Use the provided text box to specify a path on your local machine to a `mix.exs` file within one of your own projects.
When specifying a path, do not use the `~` character as an alias to the home directory.
This will not work.
Once a path to a `mix.exs` file is specified, click the `Load Graph` button to compile the application for the specified `mix.exs` file and load the graph of traced modules.
The checkbox hides modules that are not a part of the application's own code.

Here is an example graph for [Ecto](https://github.com/elixir-ecto/ecto):

[](./example.png)

# Problems

- Directions of links are not displayed
- A compiler error will show after attempting to compile a Hex dependency

# Future Work

- Expand the graph to traverse Hex dependency code
- Running the web UI as a `mix` task directly from the target application

### Special Thanks to Third Party Tools

SpiderSense was built with the [Phoenix Framework](https://phoenixframework.org/) and graph visualizations are powered by [D3 JS](https://d3js.org/).
