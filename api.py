from flask import Flask, request, jsonify
import re

app = Flask(__name__)

users_info: dict

item_id =[]
item_name = ""

users_info = {
'admin' : {
    'password': 'admin',
    'items': {}
},
}

@app.route('/api/auth/signup', methods=['POST'])
def signup():

    #check for matching usernames and valid password_list generation

    data = request.get_json()
    username = data.get('username')
    password= data.get('password')

    if username in users_info:
        return jsonify({'error': 'User already exists'}), 400
    
    if not re.search(r'[A-Z]' , password):
        return jsonify({'error': 'Password must contain at least one uppercase letter'}), 400
    elif not re.search(r'[a-z]', password):
        return jsonify({'error': 'Password must contain at least one lowercase letter'}), 400
    elif not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        return jsonify({'error': 'Password must contain at least one special character'}), 400
    else:
        pass
    
    new_user = {
    'password': password,
    'items': {}}
    
    users_info[username] = new_user

    return jsonify({'message': 'User created successfully'}), 201

@app.route('/api/auth/login', methods=['POST'])
def login():

    #check if username is in DB then check if password matches

    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if (username in users_info) & (users_info[username]['password'] == password):
        return jsonify({'message': 'Login successful'}), 200
    
    return jsonify({'error': 'Invalid credentials'}), 400

@app.route('/api/user/item/add', methods=['POST'])
def add_item():

    #Create a string named item_id and append the name to that catelog

    data = request.get_json()
    item_name = data.get('name')
    owner = data.get('owner')

    if users_info.get(owner) is None:
       return jsonify({'error': 'User not found'}), 404

    item_id = str(len(users_info[owner]['items']))

    users_info[owner]['items'][item_id] = item_name

    return jsonify({'message': 'Item added successfully'}), 201

@app.route('/api/user/item/get/<item_id>', methods=['GET'])
def get_item():

    # Check if item_id we are looking for exists in owners items then retrive it

    data = request.get_json()
    owner = data.get('owner')
    item_id = data.get('item_id')

    if users_info.get(owner) is None:
       return jsonify({'error': 'User not found'}), 404

    if item_id in users_info[owner]['items']:
        return jsonify(users_info[owner]['items'][item_id]), 200
    
    return jsonify({'error': 'Item not found'}), 404

@app.route('/api/user/item/edit', methods=['PUT'])
def edit_item():

    # Check if item exists then modify item name

    data = request.get_json()
    owner = data.get('owner')
    item_id = data.get('item_id')
    new_name = data.get('name')

    if users_info.get(owner) is None:
       return jsonify({'error': 'User not found'}), 404

    if users_info[owner]['items'].get(item_id) is None:
       return jsonify({'error': 'Item not found'}), 404
                                     
    users_info[owner]['items'][item_id] = new_name
    return jsonify({'message': 'Item updated successfully'}), 200
 

@app.route('/api/user/item/delete/<item_id>', methods=['DELETE'])
def delete_item():

    # Check if item exists and delete

    data = request.get_json()
    owner = data.get('owner')
    item_id = data.get('item_id')

    if users_info.get(owner) is None:
       return jsonify({'error': 'User not found'}), 404

    if users_info[owner]['items'].get(item_id) is None:
       return jsonify({'error': 'Item not found'}), 404
    
    del users_info[owner]['items'][item_id]
    return jsonify({'message': 'Item deleted successfully'}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
