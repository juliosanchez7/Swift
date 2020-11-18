import UIKit

var PokeCaugh: [Int] = []
class PokemonViewController: UIViewController {
    var url: String!
    var PokeId : Int!
    let defaults = UserDefaults.standard
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var Catch: UIButton!
    @IBOutlet var ImageLabel: UIImageView!
    @IBOutlet weak var PokemonDescription: UITextView!
    
    //This method is called when the catch button in clicked
    @IBAction func toggleCatch() {
        //Search if the pokemon ID is in the array of Pokemons caughs
        if PokeCaugh.contains(PokeId) {
            //If it in the array remove it
            //Remove PokeID from PokeCaugh
            PokeCaugh = PokeCaugh.filter{$0 != PokeId}
        }
        //If the id is not in the array append it
        else {
            PokeCaugh.append(PokeId)
            //Save State of the PokeCaugh array 
            defaults.set(PokeCaugh, forKey: "PokeCaugh")
        }
        setLabelCatchButton()
    }
    //function who change the lable of the catch button
    func setLabelCatchButton() {
        let lableButton = PokeCaugh.contains(PokeId) ? "Release" : "Catch"
        self.Catch.setTitle(lableButton, for: .normal)
    }
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PokeCaugh = defaults.array(forKey: "PokeCaugh") as? [Int] ?? []
        
        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        PokemonDescription.text = ""
        loadPokemon()
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    //Save the id of the pokemon in the Pokeid variable
                    self.PokeId = result.id
                    self.loadDescription()
                    //Call function who set the lable of the catch button
                    self.setLabelCatchButton()
                    let imgUrl = URL(string: result.sprites.front_default)
                    if let ImgPoke = try? Data(contentsOf: imgUrl!){
                        self.ImageLabel.image = UIImage(data : ImgPoke)
                    }
                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    func loadDescription() {
        guard let pokemonId = PokeId, let requestUrl = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(pokemonId)") else {
            return
        }
        URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonDescriptionResult.self, from: data)
                let description = result.flavor_text_entries.first(where: { $0.language.name == "en" })?.flavor_text ?? ""
                DispatchQueue.main.async {
                    self.PokemonDescription.text = description.replacingOccurrences(of: "\n", with: " ")
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
}
