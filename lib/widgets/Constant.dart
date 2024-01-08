
import 'dart:core';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Constant {
  String serverUrl = 'http://173.212.193.109:8080';
  String sendersId = '652a578b7ff9b6023a1483ba';
  String receiversId = '652b2cfe59629378c2c7dacb';
  String senderId = '652b2cfe59629378c2c7dacb';
  String publishableKey = 'pk_test_51O1mwsSBFjpzQSTJYIRROzWlVlSlOL4ysCytD2icFn57ISGbDUDaVLyLgFJABlFaHDPgMmmOpvRKxE99x3w90HRf00ZwzrVv0R';
  int tripPlaningCost = 1000;
  List<String> professionList = [
    'Doctor',
    'Engineer',
    'Teacher',
    'Software Developer',
    'Graphic Designer',
    'Accountant',
    'Chef',
    'Architect',
    'Lawyer',
    'Police Officer',
    'Firefighter',
    'Pilot',
    'Dentist',
    'Electrician',
    'Plumber',
    'Journalist',
    'Actor',
    'Musician',
    'Athlete',
    'Scientist',
    'Psychologist',
    'Social Worker',
    'Librarian',
    'Fashion Designer',
    'Marketing Manager',
    'Biologist',
    'Economist',
    'Mechanic',
    'Photographer',
    'Nurse',
    'Pharmacist',
    'Veterinarian',
    'Artist',
    'Carpenter',
    'Dancer',
    'Entrepreneur',
    'Hair Stylist',
    'Interior Designer',
    'Investment Banker',
    'Meteorologist',
    'Paramedic',
    'Physicist',
    'Speech Therapist',
    'Translator',
    'Zoologist',
    'Others'
  ];
  List<String> cityList = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Kolkata',
    'Chennai',
    'Hyderabad',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
    'Kanpur',
    'Nagpur',
    'Indore',
    'Thane',
    'Bhopal',
    'Visakhapatnam',
    'Pimpri-Chinchwad',
    'Patna',
    'Vadodara',
    'Ghaziabad',
    'Ludhiana',
    'Agra',
    'Nashik',
    'Faridabad',
    'Meerut',
    'Rajkot',
    'Varanasi',
    'Srinagar',
    'Aurangabad',
    'Dhanbad',
    'Others'
  ];
  List<String> languageList = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Russian',
    'Portuguese',
    'Italian',
    'Dutch',
    'Turkish',
    'Hindi',
    'Bengali',
    'Urdu',
    'Punjabi',
    'Tamil',
    'Telugu',
    'Marathi',
    'Gujarati',
    'Malayalam',
    'Kannada',
    'Odia',
    'Assamese',
    'Nepali',
    'Sanskrit',
    'Thai',
    'Indonesian',
    'Malay',
    'Vietnamese',
    'Tagalog',
    'Swahili',
    'Yoruba',
    'Zulu',
    'Afrikaans',
    'Farsi (Persian)',
    'Hebrew',
    'Greek',
    'Swedish',
    'Norwegian',
    'Danish',
    'Finnish',
    'Polish',
    'Hungarian',
    'Czech',
    'Slovak',
    'Romanian',
    'Bulgarian',
    'Serbian',
    'Croatian',
    'Bosnian',
    'Slovenian',
    'Macedonian',
    'Albanian',
    'Georgian',
    'Armenian',
    'Azerbaijani',
    'Kazakh',
    'Uzbek',
    'Kyrgyz',
    'Turkmen',
    'Mongolian',
    'Tibetan',
    'Burmese',
    'Khmer',
    'Lao',
    'Hmong',
    'Maori',
    'Samoan',
    'Tongan',
    'Fijian',
    'Marshallese',
    'Hawaiian',
    'Chamorro',
    'Palauan',
    'Micronesian',
    'Guaraní',
    'Quechua',
    'Aymara',
    'Nahuatl',
    'Maya',
    'Inuktitut',
    'Greenlandic',
    'Hausa',
    'Igbo',
    'Yoruba',
    'Zulu',
    'Xhosa',
    'Sesotho',
    'Tswana',
    'Shona',
    'Swazi',
    'Malagasy',
    'Mauritian Creole',
    'Seychellois Creole',
    'Chichewa',
    'Tsonga',
    'Tshiluba',
    'Lingala',
    'Kikongo',
    'Kituba',
    'Sango',
    'Kinyarwanda',
    'Kirundi',
    'Bemba',
    'Tumbuka',
    'Chewa',
    'Luganda',
    'Runyankole',
    'Rukiga',
    'Luhya',
    'Kalenjin',
    'Kisii',
    'Meru',
    'Kamba',
    'Embu',
    'Somali',
    'Amharic',
    'Tigrinya',
    'Oromo',
    'Afar',
    'Sidamo',
    'Wolaytta',
    'Gedeo',
    'Konso',
    'Hadiyya',
    'Harari',
    'Tigray',
    'Xhosa',
    'Venda',
    'Zulu',
    'Northern Sotho',
    'Tswana',
    'Swazi',
    'Khoekhoe',
    'Khoemana',
    'Nǀu',
    'N|uu',
  ];
}