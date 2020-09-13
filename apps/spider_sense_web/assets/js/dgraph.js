import * as d3 from "d3";
export const DGraph = {
  update_chart: (id) => {
    const container = d3.select("#" + id)
    const data = JSON.parse(container.attr("data-chart"));
    const svg = container.select("svg")

    // Margins
    const margin = ({top: 20, right: 30, bottom: 30, left: 40})
    const width = svg.attr("width") - margin.right
    const height = svg.attr("height") - margin.top


    const links = data.links.map(d => Object.create(d));
    const nodes = data.nodes.map(d => Object.create(d));

    const g = svg.append("g").attr("cursor", "grab")

    const simulation = d3.forceSimulation(nodes)
      .force("link", d3.forceLink(links).id(d => d.id).distance(30))
      .force("charge", d3.forceManyBody().strength(-20))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide().radius(20));

    svg.attr("viewBox", [0, 0, width, height]);

    const link = g.append("g")
      .attr("stroke", "#999")
      .attr("stroke-opacity", 0.6)
      .selectAll("line")
      .data(links)
      .join("line")
      .attr("stroke-width", d => Math.sqrt(d.value));

    const color = d => {
      const scale = d3.scaleOrdinal(d3.schemeCategory10);
      return scale(d.group);
    };

    const drag = simulation => {
      function dragstarted(event) {
        if (!event.active) simulation.alphaTarget(0.3).restart();
        event.subject.fx = event.subject.x;
        event.subject.fy = event.subject.y;
      }

      function dragged(event) {
        event.subject.fx = event.x;
        event.subject.fy = event.y;
      }

      function dragended(event) {
        if (!event.active) simulation.alphaTarget(0);
        event.subject.fx = null;
        event.subject.fy = null;
      }

      return d3.drag()
        .on("start", dragstarted)
        .on("drag", dragged)
        .on("end", dragended);
    }

    const node = g.append("g")
      .selectAll("g")
      .data(nodes)
      .join("g")

    node.append("circle")
      .attr("stroke", "#fff")
      .attr("stroke-width", 1.5)
      .join("circle")
      .attr("r", 10)
      .attr("fill", color)
      .call(drag(simulation));

    node.append("title")
      .text(d => d.id);

    node.append("text")
      .text(d => d.id)
      .attr("font-size", "4");

    simulation.on("tick", () => {
      link
        .attr("x1", d => d.source.x)
        .attr("y1", d => d.source.y)
        .attr("x2", d => d.target.x)
        .attr("y2", d => d.target.y);

      node.selectAll("circle")
        .attr("cx", d => d.x)
        .attr("cy", d => d.y);

      node.selectAll("text")
        .attr("x", d => d.x - 15)
        .attr("y", d => d.y);
    });

    function zoomed({transform}) {
      console.log(transform)
      g.attr("transform", transform)
    }

    svg.call(d3.zoom()
      .extent([[0,0], [width, height]])
      .scaleExtent([1,8])
      .on("zoom", zoomed))

    //invalidation.then(() => simulation.stop());

    return svg.node();
  }
};
