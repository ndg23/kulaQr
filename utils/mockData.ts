import type { EstablishmentData } from '~/types'

export const mockEstablishment: EstablishmentData = {
  _id: "mock-establishment-1",
  name: "Le Bistrot Parisien",
  categories: [
    {
      _id: "cat-1",
      name: "Entrées",
      products: [
        {
          _id: "prod-1",
          name: "Soupe à l'Oignon",
          description: "Soupe traditionnelle à l'oignon gratinée au fromage",
          price: 8.50
        },
        {
          _id: "prod-2",
          name: "Salade César",
          description: "Laitue romaine, croûtons, parmesan, sauce césar",
          price: 10.50
        },
        {
          _id: "prod-3",
          name: "Foie Gras Maison",
          description: "Foie gras mi-cuit, chutney de figues, pain toasté",
          price: 15.00
        }
      ]
    },
    {
      _id: "cat-2",
      name: "Plats Principaux",
      products: [
        {
          _id: "prod-4",
          name: "Steak Frites",
          description: "Entrecôte grillée, frites maison, sauce béarnaise",
          price: 24.50
        },
        {
          _id: "prod-5",
          name: "Confit de Canard",
          description: "Cuisse de canard confite, pommes sarladaises",
          price: 22.00
        },
        {
          _id: "prod-6",
          name: "Poisson du Jour",
          description: "Selon arrivage, légumes de saison",
          price: 26.00
        }
      ]
    },
    {
      _id: "cat-3",
      name: "Desserts",
      products: [
        {
          _id: "prod-7",
          name: "Crème Brûlée",
          description: "Crème vanille, caramel croustillant",
          price: 8.00
        },
        {
          _id: "prod-8",
          name: "Tarte Tatin",
          description: "Tarte aux pommes caramélisées, crème fraîche",
          price: 9.00
        },
        {
          _id: "prod-9",
          name: "Mousse au Chocolat",
          description: "Chocolat noir 70%, chantilly maison",
          price: 8.50
        }
      ]
    },
    {
      _id: "cat-4",
      name: "Boissons",
      products: [
        {
          _id: "prod-10",
          name: "Vin Rouge Maison",
          description: "Verre de 15cl",
          price: 6.00
        },
        {
          _id: "prod-11",
          name: "Eau Minérale",
          description: "Plate ou gazeuse 75cl",
          price: 4.50
        },
        {
          _id: "prod-12",
          name: "Café Expresso",
          description: "100% Arabica",
          price: 2.50
        }
      ]
    }
  ]
}

export const mockOrder: OrderData = {
  _id: "order-1",
  establishmentId: "mock-establishment-1",
  products: [
    {
      productId: "prod-1",
      name: "Soupe à l'Oignon",
      quantity: 2,
      price: 8.50
    },
    {
      productId: "prod-4",
      name: "Steak Frites",
      quantity: 1,
      price: 24.50
    }
  ],
  totalAmount: 41.50,
  status: "pending"
} 