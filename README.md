# SpiderSense

Spider Sense traverses a project's web of dependencies and displays them in the browser. The dependencies, modules and function calls are displayed using Phoenix LiveView and D3 which then can be filtered and explored.

# Get Started

Spider Sense runs as a Phoenix web application. In order to discover the web of dependencies the target project is compiled using the Tracer option. When using Spider Sense to explore your project's dependencies run it in the Spider Sense directory with:
```
mix phx.server
```
And then navigate your browser to:
```
localhost:4000
```

TODO Fill in more examples and specify usage as things develop

### Special Thanks to Third Party Tools

SpiderSense was built with the [Phoenix Framework](https://phoenixframework.org/) and graph visualizations are powered by [D3 JS](https://d3js.org/).

# Build

```
cd apps/spider_sense_web
npm install --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest
MIX_ENV=prod mix phx.server
```