#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Swift Dependency Graph Generator
--------------------------------
A tool that analyzes Swift files to identify dependencies between types and files,
builds a dependency graph, detects circular dependencies, and generates an interactive
visualization.
"""

import os
import re
import sys
import yaml
import argparse
import networkx as nx
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
import webbrowser
import json
from collections import defaultdict
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class SwiftType:
    """Represents a Swift type (class, struct, enum, protocol)"""
    name: str
    kind: str
    file_path: str
    line_number: int
    
    def __hash__(self):
        return hash((self.name, self.file_path))
    
    def __eq__(self, other):
        if not isinstance(other, SwiftType):
            return False
        return self.name == other.name and self.file_path == other.file_path

@dataclass
class Dependency:
    """Represents a dependency between two Swift types"""
    source: SwiftType
    target: str  # Target is just a string name, will be resolved later
    kind: str  # inheritance, composition, usage, etc.

    def __hash__(self):
        return hash((self.source, self.target, self.kind))
    
    def __eq__(self, other):
        if not isinstance(other, Dependency):
            return False
        return (self.source == other.source and 
                self.target == other.target and 
                self.kind == other.kind)

def load_config(config_path: str) -> Dict:
    """Load the YAML configuration file"""
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def find_swift_files(directory: str, excluded_dirs: List[str] = None) -> List[str]:
    """Find all Swift files in a directory and its subdirectories"""
    if excluded_dirs is None:
        excluded_dirs = []
        
    swift_files = []
    
    for root, dirs, files in os.walk(directory):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if d not in excluded_dirs]
        
        for file in files:
            if file.endswith('.swift'):
                swift_files.append(os.path.join(root, file))
                
    return swift_files

def extract_swift_types(file_path: str) -> List[SwiftType]:
    """Extract all Swift types from a file"""
    swift_types = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        logger.error(f"Error reading file {file_path}: {e}")
        return []
    
    # Regular expressions for different Swift types
    # Handles public/internal/private/fileprivate modifiers
    patterns = {
        'class': r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*(?:final\s+)?class\s+([A-Za-z0-9_]+)',
        'struct': r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*struct\s+([A-Za-z0-9_]+)',
        'enum': r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*enum\s+([A-Za-z0-9_]+)',
        'protocol': r'(?:^|\n)\s*(?:public\s+|internal\s+|private\s+|fileprivate\s+)*protocol\s+([A-Za-z0-9_]+)'
    }
    
    # Find all matches for each type
    for kind, pattern in patterns.items():
        for match in re.finditer(pattern, content, re.MULTILINE):
            type_name = match.group(1)
            # Get line number by counting newlines before the match
            line_number = content[:match.start()].count('\n') + 1
            swift_types.append(SwiftType(
                name=type_name,
                kind=kind,
                file_path=file_path,
                line_number=line_number
            ))
    
    return swift_types

def extract_dependencies(file_path: str, swift_types: List[SwiftType]) -> List[Dependency]:
    """Extract dependencies between Swift types in a file"""
    dependencies = []
    type_by_name = {t.name: t for t in swift_types}
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        logger.error(f"Error reading file {file_path}: {e}")
        return []
    
    # Inheritance patterns
    inheritance_pattern = re.compile(r'(?:class|struct|enum|protocol)\s+([A-Za-z0-9_]+)(?:\s*:([^{]+))')
    
    # Find inheritance relationships
    for match in inheritance_pattern.finditer(content):
        source_name = match.group(1)
        if source_name not in type_by_name:
            continue
            
        source_type = type_by_name[source_name]
        
        # Extract parent types
        if match.group(2):
            parents = match.group(2).split(',')
            for parent in parents:
                parent = parent.strip()
                if parent and not parent.startswith('UIKit.') and not parent.startswith('Foundation.'):
                    dependencies.append(Dependency(
                        source=source_type,
                        target=parent,
                        kind='inheritance'
                    ))
    
    # Usage/composition patterns
    # Look for var/let declarations with types
    usage_pattern = re.compile(r'(?:var|let)\s+[A-Za-z0-9_]+\s*:\s*(?:(?:\[?\s*([A-Za-z0-9_]+)\s*(?:<[^>]+>)?\s*\]?)|(?:\(\s*[^)]*\s*\)\s*->\s*([A-Za-z0-9_]+)))')
    
    # Find all types in the file to get source types
    for source_type in [t for t in swift_types if t.file_path == file_path]:
        # Find a rough approximation of the type's code block
        class_start = re.search(f"{source_type.kind}\\s+{source_type.name}", content)
        if not class_start:
            continue
            
        # Find the open bracket after the class declaration
        open_bracket_pos = content.find('{', class_start.end())
        if open_bracket_pos == -1:
            continue
            
        # Find the matching closing bracket (naive implementation)
        brace_count = 1
        close_bracket_pos = open_bracket_pos + 1
        while brace_count > 0 and close_bracket_pos < len(content):
            if content[close_bracket_pos] == '{':
                brace_count += 1
            elif content[close_bracket_pos] == '}':
                brace_count -= 1
            close_bracket_pos += 1
        
        if brace_count > 0:  # Couldn't find matching bracket
            close_bracket_pos = len(content)
        
        # Get the block content
        block_content = content[open_bracket_pos:close_bracket_pos]
        
        # Find all usage/composition dependencies
        for match in usage_pattern.finditer(block_content):
            target_name = match.group(1) or match.group(2)
            if target_name and target_name != source_type.name:
                # Skip primitive types and system types
                if target_name not in ['Int', 'String', 'Bool', 'Double', 'Float', 'Any', 'AnyObject']:
                    dependencies.append(Dependency(
                        source=source_type,
                        target=target_name,
                        kind='usage'
                    ))
    
    return dependencies

def build_dependency_graph(types: List[SwiftType], dependencies: List[Dependency]) -> nx.DiGraph:
    """Build a directed graph of dependencies"""
    G = nx.DiGraph()
    
    # Add all types as nodes
    for swift_type in types:
        # Create node with attributes
        G.add_node(swift_type.name, 
                  kind=swift_type.kind, 
                  file=os.path.basename(swift_type.file_path),
                  full_path=swift_type.file_path,
                  line=swift_type.line_number)
    
    # Add dependencies as edges
    for dep in dependencies:
        if dep.target in G:  # Only add dependencies to known types
            G.add_edge(dep.source.name, dep.target, kind=dep.kind)
    
    return G

def find_circular_dependencies(G: nx.DiGraph) -> List[List[str]]:
    """Find circular dependencies in the graph"""
    try:
        cycles = list(nx.simple_cycles(G))
        # Sort cycles by length (shortest first)
        cycles.sort(key=len)
        return cycles
    except nx.NetworkXNoCycle:
        return []

def suggest_break_cycles(G: nx.DiGraph, cycles: List[List[str]]) -> Dict[str, List[str]]:
    """Suggest ways to break circular dependencies"""
    suggestions = {}
    
    for cycle in cycles:
        if len(cycle) <= 1:  # Self-loops
            continue
            
        # For each cycle, suggest breaking each edge
        for i in range(len(cycle)):
            source = cycle[i]
            target = cycle[(i + 1) % len(cycle)]
            
            if G.has_edge(source, target):
                edge_kind = G.edges[source, target]['kind']
                
                if edge_kind == 'inheritance':
                    suggestion = f"Replace inheritance with composition or protocol"
                elif edge_kind == 'usage':
                    suggestion = f"Use protocols instead of concrete types or move to separate module"
                else:
                    suggestion = f"Consider restructuring this dependency"
                
                if source not in suggestions:
                    suggestions[source] = []
                suggestions[source].append(f"To {target}: {suggestion}")
    
    return suggestions

def create_html_visualization(G: nx.DiGraph, cycles: List[List[str]], suggestions: Dict[str, List[str]], output_path: str):
    """Create an interactive HTML visualization using Cytoscape.js"""
    # Convert graph to Cytoscape.js format
    cy_nodes = []
    cy_edges = []
    
    # Prepare node data
    for node in G.nodes():
        node_data = G.nodes[node]
        is_in_cycle = any(node in cycle for cycle in cycles)
        
        cy_nodes.append({
            'data': {
                'id': node,
                'label': node,
                'kind': node_data.get('kind', 'unknown'),
                'file': node_data.get('file', ''),
                'fullPath': node_data.get('full_path', ''),
                'line': node_data.get('line', 0),
                'inCycle': is_in_cycle,
                'suggestions': suggestions.get(node, [])
            }
        })
    
    # Prepare edge data
    for source, target, data in G.edges(data=True):
        is_in_cycle = any(source in cycle and target in cycle for cycle in cycles)
        
        cy_edges.append({
            'data': {
                'id': f"{source}-{target}",
                'source': source,
                'target': target,
                'kind': data.get('kind', 'unknown'),
                'inCycle': is_in_cycle
            }
        })
    
    # Create HTML with embedded Cytoscape.js
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Swift Dependency Graph</title>
        <style>
            body { 
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                margin: 0;
                padding: 0;
                display: flex;
                height: 100vh;
                background-color: #1e1e1e;
                color: #e0e0e0;
            }
            #cy {
                width: 75%;
                height: 100%;
                background-color: #121212;
            }
            #info-panel {
                width: 25%;
                padding: 20px;
                box-sizing: border-box;
                overflow: auto;
                border-left: 1px solid #444;
                background-color: #252525;
            }
            h1, h2, h3 {
                margin-top: 0;
                color: #e0e0e0;
            }
            .cycle {
                background-color: rgba(220, 53, 69, 0.2);
                border: 1px solid rgba(220, 53, 69, 0.3);
                border-radius: 4px;
                padding: 10px;
                margin-bottom: 10px;
            }
            .cycle a {
                color: #58a6ff;
                text-decoration: none;
            }
            .cycle a:hover {
                text-decoration: underline;
            }
            .suggestion {
                background-color: rgba(0, 123, 255, 0.2);
                border: 1px solid rgba(0, 123, 255, 0.3);
                border-radius: 4px;
                padding: 10px;
                margin-bottom: 10px;
            }
            .node-details {
                background-color: #333;
                border: 1px solid #444;
                border-radius: 4px;
                padding: 15px;
                margin-top: 20px;
            }
            .node-details a {
                color: #58a6ff;
                text-decoration: none;
            }
            .node-details a:hover {
                text-decoration: underline;
            }
            .filter-controls {
                margin-bottom: 20px;
                padding: 10px;
                background-color: #333;
                border: 1px solid #444;
                border-radius: 4px;
            }
            button {
                background-color: #4CAF50;
                border: none;
                color: white;
                padding: 8px 12px;
                text-align: center;
                text-decoration: none;
                display: inline-block;
                font-size: 14px;
                margin: 4px 2px;
                cursor: pointer;
                border-radius: 4px;
            }
            button.secondary {
                background-color: #6c757d;
            }
            .search-box {
                width: 100%;
                padding: 8px;
                margin-bottom: 10px;
                box-sizing: border-box;
                border: 1px solid #555;
                border-radius: 4px;
                background-color: #333;
                color: #e0e0e0;
            }
            label {
                color: #e0e0e0;
                margin-right: 8px;
            }
        </style>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.21.1/cytoscape.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/dagre/0.8.5/dagre.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/cytoscape-dagre@2.3.2/cytoscape-dagre.min.js"></script>
    </head>
    <body>
        <div id="cy"></div>
        <div id="info-panel">
            <h1>Swift Dependency Graph</h1>
            
            <div class="filter-controls">
                <h3>Filters</h3>
                <input type="text" id="search-box" class="search-box" placeholder="Search nodes...">
                <div>
                    <label><input type="checkbox" id="toggle-cycles" checked> Show only cycles</label>
                </div>
                <div>
                    <label>Show types:</label>
                    <label><input type="checkbox" id="show-class" checked> Classes</label>
                    <label><input type="checkbox" id="show-struct" checked> Structs</label>
                    <label><input type="checkbox" id="show-enum" checked> Enums</label>
                    <label><input type="checkbox" id="show-protocol" checked> Protocols</label>
                </div>
                <div>
                    <button id="reset-view">Reset View</button>
                    <button id="toggle-layout" class="secondary">Toggle Layout</button>
                </div>
            </div>
            
            <div>
                <h2>Circular Dependencies</h2>
                <div id="cycles-list"></div>
            </div>
            
            <div class="node-details" id="node-details">
                <h2>Selected Node Details</h2>
                <p>Click on a node to see details...</p>
            </div>
        </div>

        <script>
            // Graph data
            const graphData = GRAPH_DATA_PLACEHOLDER;
            
            // Initialize Cytoscape
            const cy = cytoscape({
                container: document.getElementById('cy'),
                elements: {
                    nodes: graphData.nodes,
                    edges: graphData.edges
                },
                style: [
                    {
                        selector: 'node',
                        style: {
                            'label': 'data(label)',
                            'background-color': '#3572A5',
                            'text-valign': 'center',
                            'text-halign': 'center',
                            'color': '#fff',
                            'font-size': '14px',
                            'text-wrap': 'wrap',
                            'text-max-width': '120px',
                            'width': '150px',
                            'height': '150px',
                            'text-outline-width': 1,
                            'text-outline-color': '#000'
                        }
                    },
                    {
                        selector: 'node[kind="class"]',
                        style: {
                            'background-color': '#3572A5' // Python blue
                        }
                    },
                    {
                        selector: 'node[kind="struct"]',
                        style: {
                            'background-color': '#9467bd' // Purple
                        }
                    },
                    {
                        selector: 'node[kind="enum"]',
                        style: {
                            'background-color': '#2ca02c' // Green
                        }
                    },
                    {
                        selector: 'node[kind="protocol"]',
                        style: {
                            'background-color': '#ff7f0e' // Orange
                        }
                    },
                    {
                        selector: 'node[inCycle=true]',
                        style: {
                            'border-width': '4px',
                            'border-color': '#E74C3C',
                            'border-style': 'solid'
                        }
                    },
                    {
                        selector: 'edge',
                        style: {
                            'width': 2,
                            'line-color': '#aaa',
                            'target-arrow-color': '#aaa',
                            'target-arrow-shape': 'triangle',
                            'curve-style': 'bezier'
                        }
                    },
                    {
                        selector: 'edge[kind="inheritance"]',
                        style: {
                            'line-style': 'solid',
                            'line-color': '#3498DB',
                            'target-arrow-color': '#3498DB'
                        }
                    },
                    {
                        selector: 'edge[kind="usage"]',
                        style: {
                            'line-style': 'dashed',
                            'line-color': '#95a5a6',
                            'target-arrow-color': '#95a5a6'
                        }
                    },
                    {
                        selector: 'edge[inCycle=true]',
                        style: {
                            'line-color': '#E74C3C',
                            'target-arrow-color': '#E74C3C',
                            'width': 3
                        }
                    },
                    {
                        selector: 'node:selected',
                        style: {
                            'border-width': '4px',
                            'border-color': '#FFC107',
                            'border-style': 'solid'
                        }
                    }
                ],
                layout: {
                    name: 'dagre',
                    rankDir: 'TB',
                    rankSep: 150,
                    nodeSep: 150,
                    edgeSep: 80,
                    padding: 50
                }
            });
            
            // Initialize UI
            function initUI() {
                // Populate cycles list
                const cyclesListElement = document.getElementById('cycles-list');
                if (graphData.cycles.length === 0) {
                    cyclesListElement.innerHTML = '<p>No circular dependencies found.</p>';
                } else {
                    graphData.cycles.forEach((cycle, index) => {
                        const cycleDiv = document.createElement('div');
                        cycleDiv.className = 'cycle';
                        
                        // Create clickable path
                        const cycleText = cycle.map(node => {
                            return `<a href="#" class="node-link" data-node="${node}">${node}</a>`;
                        }).join(' → ') + ` → <a href="#" class="node-link" data-node="${cycle[0]}">${cycle[0]}</a>`;
                        
                        cycleDiv.innerHTML = `<p><strong>Cycle ${index + 1}:</strong> ${cycleText}</p>`;
                        cyclesListElement.appendChild(cycleDiv);
                    });
                    
                    // Add click handlers for node links
                    document.querySelectorAll('.node-link').forEach(link => {
                        link.addEventListener('click', (e) => {
                            e.preventDefault();
                            const nodeId = e.target.getAttribute('data-node');
                            selectNode(nodeId);
                        });
                    });
                }
                
                // Setup event listeners
                cy.on('tap', 'node', function(e) {
                    const node = e.target;
                    updateNodeDetails(node.data());
                });
                
                document.getElementById('reset-view').addEventListener('click', () => {
                    cy.fit();
                });
                
                document.getElementById('toggle-layout').addEventListener('click', () => {
                    const currentLayout = cy.layout({ name: 'dagre' }).options.rankDir;
                    const newLayout = currentLayout === 'TB' ? 'LR' : 'TB';
                    
                    cy.layout({
                        name: 'dagre',
                        rankDir: newLayout,
                        rankSep: 150,
                        nodeSep: 150,
                        edgeSep: 80,
                        padding: 50
                    }).run();
                });
                
                // Setup search functionality
                document.getElementById('search-box').addEventListener('input', (e) => {
                    const searchTerm = e.target.value.toLowerCase();
                    
                    if (searchTerm === '') {
                        cy.elements().removeClass('hidden');
                        applyTypeFilters(); // Reapply type filters
                        return;
                    }
                    
                    cy.nodes().forEach(node => {
                        const nodeMatches = node.data('label').toLowerCase().includes(searchTerm) ||
                                          node.data('file').toLowerCase().includes(searchTerm);
                        
                        if (!nodeMatches) {
                            node.addClass('hidden');
                        } else {
                            node.removeClass('hidden');
                        }
                    });
                    
                    // Also hide edges to/from hidden nodes
                    cy.edges().forEach(edge => {
                        const sourceHidden = edge.source().hasClass('hidden');
                        const targetHidden = edge.target().hasClass('hidden');
                        
                        if (sourceHidden || targetHidden) {
                            edge.addClass('hidden');
                        } else {
                            edge.removeClass('hidden');
                        }
                    });
                });
                
                // Setup cycle toggle
                document.getElementById('toggle-cycles').addEventListener('change', (e) => {
                    const showOnlyCycles = e.target.checked;
                    
                    if (showOnlyCycles) {
                        // Hide nodes not in cycles
                        cy.nodes().forEach(node => {
                            if (!node.data('inCycle')) {
                                node.addClass('hidden');
                            } else {
                                node.removeClass('hidden');
                            }
                        });
                        
                        // Hide edges not in cycles
                        cy.edges().forEach(edge => {
                            if (!edge.data('inCycle')) {
                                edge.addClass('hidden');
                            } else {
                                edge.removeClass('hidden');
                            }
                        });
                    } else {
                        // Show all nodes and edges
                        cy.elements().removeClass('hidden');
                        applyTypeFilters(); // Reapply type filters
                    }
                });
                
                // Setup type filters
                ['class', 'struct', 'enum', 'protocol'].forEach(type => {
                    document.getElementById(`show-${type}`).addEventListener('change', applyTypeFilters);
                });
                
                // Apply hide style
                cy.style().selector('.hidden').style({
                    'display': 'none'
                }).update();
            }
            
            function applyTypeFilters() {
                const showClass = document.getElementById('show-class').checked;
                const showStruct = document.getElementById('show-struct').checked;
                const showEnum = document.getElementById('show-enum').checked;
                const showProtocol = document.getElementById('show-protocol').checked;
                
                // If cycle filter is active, don't override it
                if (document.getElementById('toggle-cycles').checked) {
                    return;
                }
                
                cy.nodes().forEach(node => {
                    const kind = node.data('kind');
                    
                    if ((kind === 'class' && !showClass) ||
                        (kind === 'struct' && !showStruct) ||
                        (kind === 'enum' && !showEnum) ||
                        (kind === 'protocol' && !showProtocol)) {
                        node.addClass('hidden');
                    } else {
                        node.removeClass('hidden');
                    }
                });
                
                // Also hide edges to/from hidden nodes
                cy.edges().forEach(edge => {
                    const sourceHidden = edge.source().hasClass('hidden');
                    const targetHidden = edge.target().hasClass('hidden');
                    
                    if (sourceHidden || targetHidden) {
                        edge.addClass('hidden');
                    } else {
                        edge.removeClass('hidden');
                    }
                });
            }
            
            function selectNode(nodeId) {
                const node = cy.getElementById(nodeId);
                if (node.length > 0) {
                    // Deselect any currently selected elements
                    cy.elements().unselect();
                    
                    // Select the node
                    node.select();
                    
                    // Center the view on the node
                    cy.animate({
                        fit: {
                            eles: node,
                            padding: 100
                        }
                    }, {
                        duration: 500
                    });
                    
                    // Update the details panel
                    updateNodeDetails(node.data());
                }
            }
            
            function updateNodeDetails(nodeData) {
                const detailsElement = document.getElementById('node-details');
                
                let html = `
                    <h2>${nodeData.label}</h2>
                    <p><strong>Type:</strong> ${nodeData.kind}</p>
                    <p><strong>File:</strong> ${nodeData.file}</p>
                    <p><strong>Line:</strong> ${nodeData.line}</p>
                `;
                
                if (nodeData.inCycle) {
                    html += `<p><strong>Warning:</strong> This type is part of a circular dependency!</p>`;
                    
                    if (nodeData.suggestions && nodeData.suggestions.length > 0) {
                        html += `<h3>Suggestions to Break Cycles:</h3>`;
                        html += `<ul>`;
                        nodeData.suggestions.forEach(suggestion => {
                            html += `<li>${suggestion}</li>`;
                        });
                        html += `</ul>`;
                    }
                }
                
                // Show incoming dependencies
                const incomingEdges = cy.edges(`[target = "${nodeData.id}"]`);
                if (incomingEdges.length > 0) {
                    html += `<h3>Used by:</h3><ul>`;
                    incomingEdges.forEach(edge => {
                        const sourceId = edge.source().id();
                        const kind = edge.data('kind');
                        html += `<li><a href="#" class="node-link" data-node="${sourceId}">${sourceId}</a> (${kind})</li>`;
                    });
                    html += `</ul>`;
                }
                
                // Show outgoing dependencies
                const outgoingEdges = cy.edges(`[source = "${nodeData.id}"]`);
                if (outgoingEdges.length > 0) {
                    html += `<h3>Uses:</h3><ul>`;
                    outgoingEdges.forEach(edge => {
                        const targetId = edge.target().id();
                        const kind = edge.data('kind');
                        html += `<li><a href="#" class="node-link" data-node="${targetId}">${targetId}</a> (${kind})</li>`;
                    });
                    html += `</ul>`;
                }
                
                detailsElement.innerHTML = html;
                
                // Add click handlers for node links
                document.querySelectorAll('.node-link').forEach(link => {
                    link.addEventListener('click', (e) => {
                        e.preventDefault();
                        const linkNodeId = e.target.getAttribute('data-node');
                        selectNode(linkNodeId);
                    });
                });
            }
            
            // Initialize the UI once the document is loaded
            document.addEventListener('DOMContentLoaded', initUI);
        </script>
    </body>
    </html>
    """
    
    # Prepare data for the graph
    graph_data = {
        'nodes': cy_nodes,
        'edges': cy_edges,
        'cycles': cycles
    }
    
    # Replace placeholder with actual graph data
    html_content = html_content.replace('GRAPH_DATA_PLACEHOLDER', json.dumps(graph_data))
    
    # Write the HTML file
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    # Open the HTML file in the default browser
    webbrowser.open('file://' + os.path.abspath(output_path))

def main():
    parser = argparse.ArgumentParser(
        description='Generate a dependency graph for Swift projects'
    )
    parser.add_argument(
        'config_path',
        help='Path to the YAML configuration file'
    )
    args = parser.parse_args()
    
    config = load_config(args.config_path)
    
    project_dir = config['project_directory']
    excluded_dirs = config.get('excluded_directories', [])
    output_path = config.get('output_file', 'dependency_graph.html')
    
    logger.info(f"Analyzing Swift project in: {project_dir}")
    
    # Find all Swift files
    swift_files = find_swift_files(project_dir, excluded_dirs)
    logger.info(f"Found {len(swift_files)} Swift files")
    
    # Extract all types
    all_types = []
    for file_path in swift_files:
        all_types.extend(extract_swift_types(file_path))
    logger.info(f"Found {len(all_types)} Swift types")
    
    # Extract dependencies
    all_dependencies = []
    for file_path in swift_files:
        file_types = [t for t in all_types if t.file_path == file_path]
        all_dependencies.extend(extract_dependencies(file_path, all_types))
    logger.info(f"Found {len(all_dependencies)} dependencies")
    
    # Build the dependency graph
    G = build_dependency_graph(all_types, all_dependencies)
    logger.info(f"Built dependency graph with {G.number_of_nodes()} nodes and {G.number_of_edges()} edges")
    
    # Find circular dependencies
    cycles = find_circular_dependencies(G)
    if cycles:
        logger.info(f"Found {len(cycles)} circular dependencies")
        for i, cycle in enumerate(cycles[:10]):  # Show first 10 cycles
            logger.info(f"Cycle {i+1}: {' -> '.join(cycle)} -> {cycle[0]}")
        if len(cycles) > 10:
            logger.info(f"... and {len(cycles) - 10} more cycles")
    else:
        logger.info("No circular dependencies found")
    
    # Suggest ways to break cycles
    suggestions = suggest_break_cycles(G, cycles)
    if suggestions:
        logger.info(f"Generated suggestions for breaking {len(suggestions)} cycles")
    
    # Create visualization
    logger.info(f"Generating HTML visualization to {output_path}")
    create_html_visualization(G, cycles, suggestions, output_path)
    logger.info(f"Done! Your dependency graph has been generated.")
    
if __name__ == "__main__":
    main() 