# CRIANDO O BD
use Animals

# Inserindo apenas um dado por vez, lembrando que isso é um exemplo, os dados
# reais estão no arquivo endangered_animals_mock.json
db.endangered_animals.insertOne( {
    "_id": 1,
    "name": "Tigre de Bengala",
    "origin_continent": "Ásia",
    "population": 2500,
    "species": "Panthera tigris tigris",
    "threats": [
      "Caça furtiva",
      "Perda de habitat"
    ],
    "status": "Criticamente em perigo"
  } )

# Inserindo vários dados de uma vez, lembrando que isso é um exemplo, os dados
# reais estão no arquivo endangered_animals_mock.json
db.endangered_animals.insertMany([ {
    "_id": 2,
    "name": "Orangotango de Sumatra",
    "origin_continent": "Ásia",
    "population": 14000,
    "species": "Pongo abelii",
    "threats": [
      "Desmatamento",
      "Expansão agrícola",
      "Caça"
    ],
    "status": "Criticamente em perigo"
  },
  {
    "_id": 3,
    "name": "Leopardo-da-pérsia",
    "origin_continent": "Ásia",
    "population": 871,
    "species": "Panthera pardus saxicolor",
    "threats": [
      "Caça furtiva",
      "Desmatamento"
    ],
    "status": "Criticamente em perigo"
  },
  {
    "_id": 4,
    "name": "Rinoceronte-de-sumatra",
    "origin_continent": "Ásia",
    "population": 80,
    "species": "Dicerorhinus sumatrensis",
    "threats": [
      "Caça furtiva",
      "Perda de habitat"
    ],
    "status": "Criticamente em perigo"
  } ])

# Update e Set
# Atualizando apenas um dado

db.endangered_animals.updateOne( {
		name: "Leopardo-da-pérsia",
		species: "Panthera pardus saxicolor",
	},
	{ $set: { population: 0, status: "Extinto" } }
)


# Atualizando vários dados
db.endangered_animals.updateMany( {
		origin_continent: "Asia"
	},
	{
		$set: { origin_continent: "Ásia" }
	} 
)


# Delete
db.endangered_animals.deleteOne( { name: "Tigre-de-bengala" } )

db.endangered_animals.deleteMany( { origin_continent: "América do Norte" } )

# para deletar todos os registros
# usar apenas se necessário:
db.endangered_animals.deleteMany({})


# Find
db.endangered_animals.find()

db.endangered_animals.find({ name: "Foca-monge-do-havaí" })

db.endangered_animals.find({ origin_continent: "África" }).limit(2)

db.endangered_animals.find({ population: { $lte: 2000 } })


# Limit
db.endangered_animals.find().limit(5)

# $Match
db.endangered_animals.aggregate(
  [ { $match : { origin_continent : "Global" } } ]
);

#$Sort
db.endangered_animals.updateMany(
  { _id: 1},
  {
    $push: {
       threats: {
         $each: ["Tráfico de animais"],
         $sort: { population: 1 }
       }
    }
  }
)


# Max
db.endangered_animals.update(
	{ name: "Pangolim" },
	{ $max: { population: 600 } }
)


# não vai alterar o population, pois é menor
db.endangered_animals.update(
	{ author: "Pangolim", population: 600 },
	{ $max: { population: 300 } }
)


#Size & Count

# SIZE -> OPERATOR
# operando sobre array
db.endangered_animals.find( { threats: { $size: 2 } } );



# COUNT -> FUNCTION
db.endangered_animals.count()
# ou
db.runCommand({count: 'endangered_animals'})

# contagem dos animais em extinção com a população maior que 10000
db.runCommand( { count:'endangered_animals',
                 query: { population: { $gt: 10000 } }
               } )


#AVG & Group
db.endangered_animals.aggregate(
	[
		{
       $group:
         {
					 _id: "$origin_continent",
           populationAVG: { $avg: "$population" }
         }
     }
	]
)

#$sum
db.endangered_animals.aggregate(
  [
    {
      $group:
        {
          _id: "$origin_continent",
          totalPopulationByContinent: { $sum: "$population" },
          qtd_animals: { $sum: 1 }
        }
    }
  ]
)

#$gte
db.endangered_animals.find( { population: { $gte: 2000 } } )


# mapReduce() & function()
db.endangered_animals.mapReduce(
  function() { emit( this.origin_continent, this.population ); },
  function(key, values) { return Array.sum( values ) },
  {
    query: { origin_continent: "África" },
    out: "total_populational_by_continent"
  }
)

# para visualizar o resultado
db.total_populational_by_continent.find().pretty()


# Aggregate()
db.endangered_animals.aggregate([
  { $match: { status: "Em perigo" } },
  { $group: { _id: "$origin_continent", total: { $sum: "$population" } } },
  { $sort: { total: -1 } }
])


#$exists

# Retorna todos os documentos com valores existentes no campo "population"
#incluindo nulos
db.endangered_animals.find( { population: { $exists: true } } )


# Retorna todos os documentos que não contêm o valor em "population", como
# colocamos um documento sem o campo population, então rode:
db.endangered_animals.find( { population: { $exists: false } } )


#$where
# { $where: <string|JavaScript Code> }

# Considere o animal “Leão africano” o regex abaixo corresponde a essa String:
db.endangered_animals.find( { $where: function() {
  return (hex_md5(this.name) == "c646888cce132b8208d0526af900c322")
} } );


#pretty()
db.endangered_animals.find().pretty()


#$all
{ threats: { $all: ["Caça furtiva", "Perda de Habitat"] } }

# Que é semelhante a
{ $and: [ { threats: "Caça furtiva" }, { threats: "Perda de Habitat" } ] }

# e a
{ threats: ["Caça furtiva", "Perda de Habitat"] }


# Consultas
db.endangered_animals.find({ threats: { $all: ["Caça furtiva", "Perda de Habitat"] } })
db.endangered_animals.find({ threats: { $all: ["Desmatamento"] } })


#$filter
db.endangered_animals.updateOne( {
  name: "Viúva-negra",
  origin_continent: "América do Norte"
},
{ $set: { predators: [
      { name: "Sapos", type: "Anfíbios", "population" : 2000000 },
      { name: "Pássaros", type: "Ovíparos", "population" : 50000000 },
      { name: "Lagartixas", type: "Réptil", "population" : 40000000 }
    ] 
  } 
}
)

#Agora temos um documento com o seguinte formato:
{
	"_id" : 49,
	"name" : "Viúva-negra",
	"origin_continent" : "América do Norte",
	"population" : 60000,
	"species" : "Latrodectus",
	"threats" : [
		"destruição do habitat",
		"uso de pesticidas",
		"mudanças climáticas"
	],
	"status" : "Menos preocupante",
	"predators" : [
		{
			"name" : "Sapos",
			"type" : "Anfíbios",
      "population" : 2000000
		},
		{
			"name" : "Pássaros",
			"type" : "Ovíparos",
			"population" : 50000000
		},
		{
			"name" : "Lagartixas",
			"type" : "Réptil",
			"population" : 40000000
		}
	]
}

#Nesse momento podemos usar o $filter para obtermos os predadores com população maior que 40.000.000. 
#O resultado será uma lista completa com todos documentos aqueles que não tem valor correspondente armazenam 
#null caso tenha o campo mas não tenham dados correspondentes mostrará um array vazio e os que correspondem 
#mostram apenas o livro com a avaliação requerida(array).
db.endangered_animals.aggregate([
  {
     $project: {
        predators: {
           $filter: {
              input: "$predators",
              as: "predators",
              cond: { $gte: [ "$$predators.population", 40000000 ] }
           }
        }
     }
  }
])
#Para visualizar o resultado vá escrevendo “it” e enter no terminal.


#$text & $search
db.endangered_animals.createIndex({ name: "text" }, { language_override: "portuguese" })

db.endangered_animals.find({ $text: { $search: "Gorila" } })

#para encontrar com "Gorila", mas sem o "Ocidental"
db.endangered_animals.find( { $text: { $search: "Gorila -Ocidental" } } )

# para encontrar vários
db.endangered_animals.find( { $text: { $search: "Gorial Leão Pinguim" } } )


#definir languagem
db.endangered_animals.find( { $text: { $search: "Gorila", $language: "pt" } } )


#findOne()
db.endangered_animals.findOne({ status: "Criticamente em perigo" })


#$addToSet

#Suponha que temos o seguinte documento:
{
  "_id": 43,
  "name": "Sapo de Rabo de Leque",
  "origin_continent": "América do Sul",
  "population": 2500,
  "species": "Atelopus cruciger",
  "threats": [
    "fungo quitrídio",
    "perda de habitat"
  ],
  "status": "Criticamente em perigo"
}

#Se executarmos agora:
db.endangered_animals.updateOne(
  { _id: 43 },
  { $addToSet: { threats: "caça" } }
)

#Teremos
{
	"_id" : 43,
	"name" : "Sapo de Rabo de Leque",
	"origin_continent" : "América do Sul",
	"population" : 2500,
	"species" : "Atelopus cruciger",
	"threats" : [
		"fungo quitrídio",
		"perda de habitat",
		"caça"
	],
	"status" : "Criticamente em perigo"
}

#ou use o operador $each para adicionar vários elementos ao Array
db.endangered_animals.updateOne(
  { _id: 43 },
  { $addToSet: { threats: { $each: [ "predadorismo", "caça"] } } }
).pretty()

# saída
{
	"_id" : 43,
	"name" : "Sapo de Rabo de Leque",
	"origin_continent" : "América do Sul",
	"population" : 2500,
	"species" : "Atelopus cruciger",
	"threats" : [
		"fungo quitrídio",
		"perda de habitat",
		"caça",
		"predadorismo"
	],
	"status" : "Criticamente em perigo"
}

# Cond & Project

db.endangered_animals.aggregate([{
  $project:
  {
    title: 1,
    extinctionSituation: {
              $cond: { 
                        if: { $gte: ["$population", 5000] },
                        then: "Fora do risco alto",
                        else: "Dentro do risco alto"
    }
  }
}
}]).pretty()

# Lookup
db.animals_info.insertMany([
	{
		"animal_name": "Tigre de Bengala",
		"puppies_per_litter": 4 
	},
	{
		"animal_name": "Orangotango de Sumatra",
		"puppies_per_litter": 2
	},
	{
		"animal_name": "Leopardo-da-pérsia",
		"puppies_per_litter": 4
	},
	{
		"animal_name": "Rinoceronte-de-sumatra",
		"puppies_per_litter": 1
	},
	{
		"animal_name": "Pangolim",
		"puppies_per_litter": 1 
	},
])

# Agora vamos ver o estágio em funcionamento:

db.animals_info.aggregate( [
  {
    $lookup:
      {
        from: "endangered_animals",
        localField: "animal_name",
        foreignField: "name",
        as: "endangered_animal"
      }
 }
] ).pretty()

# renameCollection()
db.endangered_animals.renameCollection('endangered')

# Para voltar ao estado anterior
db.endangered.renameCollection('endangered_animals')

# Save
db.endangered_animals.save({
  "_id": 51,
  "name": "Lobo-guará",
  "origin_continent": "América do Sul",
  "population": 5000,
  "species": "Chrysocyon brachyurus",
  "threats": [
    "perda de habitat",
    "atropelamentos",
    "caça"
  ],
  "status": "Em perigo"
})