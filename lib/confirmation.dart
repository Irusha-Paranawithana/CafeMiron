import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatefulWidget {
  final List<Map<String, dynamic>> orderList;

  OrderConfirmationPage({required this.orderList});

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var orderData in widget.orderList)
              OrderItemWidget(orderData: orderData),
          ],
        ),
      ),
    );
  }
}

class OrderItemWidget extends StatelessWidget {
  final Map<String, dynamic> orderData;

  OrderItemWidget({required this.orderData});

  @override
  Widget build(BuildContext context) {
    int quantity = orderData['quantity']; // Get the quantity from orderData

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Display item image
          Image.network(
            orderData['imageUrl'],
            width: 120.0,
            height: 120.0,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16.0),

          // Display item name
          Text(
            orderData['title'],
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),

          // Display total price
          Text(
            'Total Price: \$${(double.parse(orderData['price']) * quantity).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 16.0),

          // Editable quantity
          Row(
            children: [
              Text(
                'Quantity: ',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                quantity.toString(),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // Delivery method option
          Text(
            'Delivery Method:',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          // Implement radio buttons for the delivery method as you did before

          SizedBox(height: 32.0),

          // Confirm and Cancel buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Implement logic to confirm the order here
                  // For example, save the updated order data
                },
                child: Text('Confirm Order'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement logic to cancel the order here
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text('Cancel Order'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
