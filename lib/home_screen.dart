import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'contact.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  PhoneNumber number = PhoneNumber(isoCode: 'VE');

  List<Contact> contacts = [];
  late String phone;

  bool isPhoneValid = false;
  bool isNameValid = false;

  int? indexEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Lista de Contactos",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 30,
        ),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  isNameValid = true;
                } else {
                  isNameValid = false;
                }

                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                hintText: 'Nombre del contacto',
                filled: true,
                fillColor: Colors.grey[200],
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    )),
              ),
            ),
            const SizedBox(height: 10),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                phone = number.phoneNumber!;
              },
              onInputValidated: (bool value) {
                isPhoneValid = value;
                setState(() {});
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Colors.black),
              initialValue: number,
              textFieldController: phoneController,
              formatInput: true,
              inputDecoration: InputDecoration(
                hintText: 'Numero del contacto',
                filled: true,
                fillColor: Colors.grey[200],
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    )),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: isPhoneValid && isNameValid
                      ? () {
                          final String name = nameController.text;

                          if (indexEdit == null) {
                            // add
                            contacts.add(Contact(name: name, phone: phone));
                          } else {
                            // update
                            contacts[indexEdit!] =
                                Contact(name: name, phone: phone);
                          }

                          FocusScope.of(context).unfocus();
                          nameController.clear();
                          phoneController.clear();
                          isPhoneValid = false;
                          isNameValid = false;
                          indexEdit = null;

                          setState(() {});
                        }
                      : null,
                  child: const Text('Guardar / Actualizar'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    nameController.clear();
                    phoneController.clear();
                    isPhoneValid = false;
                    isNameValid = false;
                    indexEdit = null;

                    setState(() {});
                  },
                  child: const Text('Cancelar'),
                )
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  return myListTile(index);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget myListTile(int index) {
    final contact = contacts[index];
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.primaries[contact.name.length],
          child: Text(contact.name[0].toUpperCase()),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.name),
            Text(contact.phone, style: TextStyle(color: Colors.grey[700]))
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  nameController.text = contact.name;
                  phoneController.text = contact.phone;

                  indexEdit = index;

                  number = await PhoneNumber.getRegionInfoFromPhoneNumber(
                      contact.phone);
                  setState(() {});
                },
                child: const Icon(Icons.edit),
              ),
              InkWell(
                  onTap: () {
                    contacts.removeAt(index);
                    setState(() {});
                  },
                  child: const Icon(Icons.remove_circle_outline_outlined))
            ],
          ),
        ),
      ),
    );
  }
}
