import UIKit

class NotesListViewController: UITableViewController {
    var notes: [Note] = []
    var note: Note? = nil
    
    @IBAction func createNote() {
        let _ = NoteManager.shared.create()
        reload()
    }
    
    func reload() {
        notes = NoteManager.shared.getNotes()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].content
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NoteSegue",
                let destination = segue.destination as? NoteViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            destination.note = notes[index]
        }
    }
    // this method handles row deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            // remove the item from the data model
            NoteManager.shared.deleteNote(note: notes[indexPath.row])
            reload()
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
}
