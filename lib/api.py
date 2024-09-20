from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
import re

app = Flask(__name__)
CORS(app)

users = {
    'admin': {
        'password': 'admin',
        "items": [
            {"item_id": "0", "name": "apple"},
            {"item_id": "1", "name": "banana"}
        ]
    },
    'admin2': {
        'password': 'admin2',
        "items": [
            {"item_id": "0", "name": "orange"},
            {"item_id": "1", "name": "berry"}
        ]
    }
}

@app.route("/api")
def home():
    return "Welcome" 

@app.route('/api/signup', methods=['POST'])
def signup():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if username in users:
        return jsonify({'error': 'User already exists'}), 400
    
    if username == '':
        return jsonify({'error': 'Invalid Username'}), 400
    
    if not re.search(r'[A-Z]', password):
        return jsonify({'error': 'Password must contain at least one uppercase letter'}), 400
    elif not re.search(r'[a-z]', password):
        return jsonify({'error': 'Password must contain at least one lowercase letter'}), 400
    elif not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        return jsonify({'error': 'Password must contain at least one special character'}), 400

    users[username] = {
        'password': password,
        'items': []
    }

    return jsonify({'message': 'User created successfully'}), 201

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if username == '':
        return jsonify({'error': 'Enter a Username'}), 400
    elif password == '':
        return jsonify({'error': 'Enter a Password'}), 400    
    elif username in users and users[username]['password'] == password:
        return jsonify({'message': 'Login Successful'}), 200

    return jsonify({'error': 'Invalid Credentials'}), 400

@app.route('/api/<user>/item/get', methods=['GET'])
def get_item(user):
    if user not in users:
        return jsonify({'error': 'User not found'}), 404

    items = users[user]['items']
    return jsonify({'items': items}), 200

@app.route('/api/<user>/item/add', methods=['POST'])
def add_item(user):
    data = request.get_json()
    item_name = data.get('name')

    if user not in users:
        return jsonify({'error': 'User not found'}), 404
    
    if item_name == '':
        return jsonify({'error': 'Enter an Item name'}), 400

    item_id = str(len(users[user]['items']))
    users[user]['items'].append({"item_id": item_id, "name": item_name})

    return jsonify({'message': 'Item added successfully'}), 201

@app.route('/api/<user>/item/edit', methods=['PUT'])
def edit_item(user):
    data = request.get_json()
    item_id = data.get('item_id')
    new_name = data.get('name')

    if user not in users:
        return jsonify({'error': 'User not found'}), 404
    
    if new_name == '':
        return jsonify({'error':'Enter a New Name '})

    item = next((item for item in users[user]['items'] if item['item_id'] == item_id), None)
    
    if item is None:
        return jsonify({'error': f'Item not found id: {item_id}'}), 404

    item['name'] = new_name
    return jsonify({'message': 'Item updated successfully'}), 200

@app.route('/api/<user>/item/delete', methods=['DELETE'])
def delete_item(user):
    data = request.get_json()
    item_id = data.get('item_id')

    if user not in users:
        return jsonify({'error': 'User not found'}), 404

    item = next((item for item in users[user]['items'] if item['item_id'] == item_id), None)

    if item is None:
        return jsonify({'error': f'Item not found id: {item_id}'}), 404

    users[user]['items'].remove(item)
    return jsonify({'message': 'Item deleted successfully'}), 200

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")
