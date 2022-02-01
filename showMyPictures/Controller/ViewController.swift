//
//  ViewController.swift
//  showMyPictures
//
//  Created by António Rocha on 03/12/2021.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pictures = [Picture]()
    
    // MARK: - View Load e Reload
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPicture))
        
        performSelector(inBackground: #selector(loadSavedData), with: nil)
    }
    
    @objc func reload() {
        tableView.reloadData()
    }
    
    // MARK: - Load and Save Data
    
    @objc func loadSavedData() {
        let defaults = UserDefaults.standard

        if let savedPictures = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                pictures = try jsonDecoder.decode([Picture].self, from: savedPictures)
            } catch {
                print("Failed to load pictures.")
            }
        }
        performSelector(onMainThread: #selector(reload), with: nil, waitUntilDone: false)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        } else {
            print("Failed to save pictures")
        }
    }
    
    // MARK: - Override of TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath) as? PictureCell else {
            fatalError("Unable to dequeue PictureCell.")
        }
           
        let picture = pictures[indexPath.item]
        
        cell.captionLabel.text = picture.caption
        
        let path = getDocumentsDirectory().appendingPathComponent(picture.filename)
        picture.filePath = path
        cell.myImageView.image = UIImage(contentsOfFile: path.path)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let picture = pictures[indexPath.item]
        
        let ac = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Show", style: .default, handler:{ action in
            self.show(this: picture)
        }))
        ac.addAction(UIAlertAction(title: "Rename", style: .default, handler:{ action in
            self.edit(this: picture)
        }))
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler:{ action in
            self.delete(this: picture)
        }))
        
        present(ac, animated: true)
    }
    
    // MARK: - Add, Show, Edit, Delete and Save
    
    @objc func addNewPicture() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        let picture = Picture(filename: imageName, caption: "Unknown", filePath: imagePath)
        pictures.append(picture)
        save()
        reload()
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths)
        return paths[0]
    }
    
    func show(this picture: Picture) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.SelectedPictureCaption = picture.caption
            vc.selectedPictureFilePath = picture.filePath
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func edit(this picture: Picture) {
        let ac = UIAlertController(title: "Rename picture", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newCaption = ac?.textFields?[0].text else { return }
            picture.caption = newCaption
            self?.save()
            self?.reload()
        })
        present(ac, animated: true)
    }
    
    func delete(this picture: Picture) {
        if let index = pictures.firstIndex(of: picture) {
            pictures.remove(at: index)
        }
        save()
        reload()
        
        let ac = UIAlertController(title: "Deletion Completed", message: "Image has been deleted.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
