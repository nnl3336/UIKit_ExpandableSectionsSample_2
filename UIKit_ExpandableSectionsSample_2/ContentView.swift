//
//  ContentView.swift
//  UIKit_ExpandableSectionsSample_2
//
//  Created by Yuki Sasaki on 2025/09/21.
//

import SwiftUI
import CoreData

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            DisclosureTableView()
                .navigationTitle("Disclosure Demo")
        }
    }
}


struct DisclosureTableView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> DisclosureTableViewController {
        let vc = DisclosureTableViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DisclosureTableViewController, context: Context) {
        // 必要に応じてデータ更新や再読み込み
    }
}


class DisclosureTableViewController: UITableViewController {
    
    class Node {
        let title: String
        var children: [Node]
        var isExpanded: Bool = false
        init(title: String, children: [Node] = []) {
            self.title = title
            self.children = children
        }
    }
    
    var data: [Node] = []
    var flatData: [Node] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // サンプルデータ
        data = [
            Node(title: "Fruits", children: [
                Node(title: "Apple"),
                Node(title: "Banana"),
                Node(title: "Citrus", children: [
                    Node(title: "Orange"),
                    Node(title: "Lemon")
                ])
            ]),
            Node(title: "Vegetables", children: [
                Node(title: "Carrot"),
                Node(title: "Broccoli")
            ])
        ]
        
        flatData = flatten(nodes: data)
    }

    func flatten(nodes: [Node]) -> [Node] {
        var result: [Node] = []
        for node in nodes {
            result.append(node)
            if node.isExpanded {
                result.append(contentsOf: flatten(nodes: node.children))
            }
        }
        return result
    }
    
    func removeDescendants(of node: Node, from flatData: inout [Node]) {
        for child in node.children {
            if let index = flatData.firstIndex(where: { $0 === child }) {
                flatData.remove(at: index)
                if child.isExpanded {
                    child.isExpanded = false
                    removeDescendants(of: child, from: &flatData)
                }
            }
        }
    }


    func getLevel(of node: Node) -> Int {
        func search(_ nodes: [Node], level: Int) -> Int? {
            for n in nodes {
                if n === node { return level }
                if let l = search(n.children, level: level + 1) { return l }
            }
            return nil
        }
        return search(data, level: 0) ?? 0
    }

    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flatData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = flatData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = .none
        let level = getLevel(of: node)
        cell.indentationLevel = level
        cell.indentationWidth = 20
        cell.textLabel?.text = node.title
        
        // 子ノードがある場合は矢印
        if !node.children.isEmpty {
            let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
            arrow.tintColor = .systemGray
            arrow.transform = node.isExpanded ? CGAffineTransform(rotationAngle: .pi/2) : .identity
            arrow.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleNode(_:)))
            arrow.addGestureRecognizer(tap)
            tap.view?.tag = indexPath.row
            cell.accessoryView = arrow
        } else {
            cell.accessoryView = nil
        }
        
        // Folder アイコンをテキストの前に
        if !node.children.isEmpty {
            cell.imageView?.image = UIImage(systemName: "folder.fill")
        } else {
            cell.imageView?.image = UIImage(systemName: "doc.fill")
        }
        
        cell.imageView?.tintColor = .systemBlue
        
        return cell
    }

    
    // MARK: - Toggle Node
    
    @objc func toggleNode(_ sender: UITapGestureRecognizer) {
        guard let row = sender.view?.tag else { return }
        let node = flatData[row]
        guard !node.children.isEmpty else { return }

        node.isExpanded.toggle()
        
        tableView.beginUpdates()
        
        let startIndex = row + 1
        let indexPaths = node.children.enumerated().map { (i, _) in
            IndexPath(row: startIndex + i, section: 0)
        }
        
        if node.isExpanded {
            // 展開 → flatData に子を挿入
            flatData.insert(contentsOf: node.children, at: startIndex)
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            // 折りたたみ → flatData から子を削除
            flatData.removeSubrange(startIndex..<startIndex + node.children.count)
            tableView.deleteRows(at: indexPaths, with: .fade)
        }

        // 矢印回転
        if let arrow = tableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryView as? UIImageView {
            UIView.animate(withDuration: 0.25) {
                arrow.transform = node.isExpanded ? CGAffineTransform(rotationAngle: .pi/2) : .identity
            }
        }
        
        tableView.endUpdates()
    }
}

func flatten(nodes: [Node]) -> [Node] {
    var result: [Node] = []
    for node in nodes {
        result.append(node)
        if node.isExpanded {
            result.append(contentsOf: flatten(nodes: node.children))
        }
    }
    return result
}

var flatData: [Node] = flatten(nodes: data)




let data: [Node] = [
    Node(title: "Fruits", children: [
        Node(title: "Apple"),
        Node(title: "Banana"),
        Node(title: "Citrus", children: [
            Node(title: "Orange"),
            Node(title: "Lemon")
        ])
    ]),
    Node(title: "Vegetables", children: [
        Node(title: "Carrot"),
        Node(title: "Broccoli")
    ])
]


class Node {
    let title: String
    var children: [Node]
    var isExpanded: Bool = false
    
    init(title: String, children: [Node] = []) {
        self.title = title
        self.children = children
    }
}
