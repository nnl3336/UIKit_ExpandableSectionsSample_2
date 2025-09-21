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

    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flatData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let node = flatData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // インデントで階層を表現
        let level = getLevel(of: node)
        cell.indentationLevel = level
        cell.indentationWidth = 20
        
        cell.textLabel?.text = node.title
        
        let arrow = UIImageView(image: UIImage(systemName: node.isExpanded ? "chevron.down" : "chevron.right"))
        arrow.tintColor = .systemGray
        cell.accessoryView = arrow

        cell.selectionStyle = .none
        cell.accessoryView?.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleNode(_:)))
        cell.accessoryView?.addGestureRecognizer(tap)
        tap.view?.tag = indexPath.row // 後でどのノードか判定する

        
        // アクセサリ矢印
        if !node.children.isEmpty {
            let imageName = node.isExpanded ? "chevron.down" : "chevron.right"
            cell.accessoryView = UIImageView(image: UIImage(systemName: imageName))
        } else {
            cell.accessoryView = nil
        }

        return cell
    }
    
    @objc func toggleNode(_ sender: UITapGestureRecognizer) {
        guard let row = sender.view?.tag else { return }
        let node = flatData[row]
        guard !node.children.isEmpty else { return }

        node.isExpanded.toggle()
        
        let oldFlatData = flatData
        flatData = flatten(nodes: data)
        
        tableView.beginUpdates()
        
        if node.isExpanded {
            // 展開 → 新しい行を挿入
            let startIndex = row + 1
            let endIndex = startIndex + node.children.count
            let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            // 折りたたみ → 子行を削除
            let startIndex = row + 1
            let countToRemove = oldFlatData.count - flatData.count
            let indexPaths = (startIndex..<startIndex + countToRemove).map { IndexPath(row: $0, section: 0) }
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        
        // 矢印回転アニメーション
        if let arrow = tableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryView as? UIImageView {
            UIView.animate(withDuration: 0.25) {
                arrow.transform = node.isExpanded ? CGAffineTransform(rotationAngle: .pi/2) : .identity
            }
        }
        
        tableView.endUpdates()
    }


    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = flatData[indexPath.row]
        guard !node.children.isEmpty else { return }

        node.isExpanded.toggle()
        flatData = flatten(nodes: data)
        tableView.reloadData()
    }

    // 階層の深さを取得
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
