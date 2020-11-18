import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    //Creating the IBOutlet (Dont forget to drag and drop in storyboard!!!)
    @IBOutlet var searchBar: UISearchBar!
    var pokemon: [PokemonListResult] = []
    //Results of the search made by the user
    var filteredPokemon: [PokemonListResult] = []
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the delegate property or our search bar
        //When the user changes the text in sear bar, func SearchBar method will be called
        searchBar.delegate = self
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                //Display all results first
                self.filteredPokemon = self.pokemon
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    //Metod that is called whe the user change the text in the searchBar:
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredPokemon = pokemon
            } else {
                filteredPokemon = []
                for p in pokemon {
                    if p.name.contains(searchText.lowercased()) {
                        filteredPokemon.append(p)
                    }
                }
            }
            tableView.reloadData()
        }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredPokemon.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        cell.textLabel?.text = capitalize(text: filteredPokemon[indexPath.row].name)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            destination.url = filteredPokemon[index].url
        }
    }
}
