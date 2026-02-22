/// Country, State and City Data for location selection
class CountryData {
  static const Map<String, CountryInfo> countries = {
    'india': CountryInfo(
      name: 'India',
      code: 'india',
      flag: '🇮🇳',
      states: {
        'andhra_pradesh': StateInfo(
          name: 'Andhra Pradesh',
          code: 'andhra_pradesh',
          cities: ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool', 'Rajahmundry', 'Tirupati', 'Kakinada', 'Kadapa', 'Anantapur'],
        ),
        'arunachal_pradesh': StateInfo(
          name: 'Arunachal Pradesh',
          code: 'arunachal_pradesh',
          cities: ['Itanagar', 'Naharlagun', 'Pasighat', 'Tawang', 'Ziro', 'Bomdila'],
        ),
        'assam': StateInfo(
          name: 'Assam',
          code: 'assam',
          cities: ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon', 'Tinsukia', 'Tezpur', 'Bongaigaon'],
        ),
        'bihar': StateInfo(
          name: 'Bihar',
          code: 'bihar',
          cities: ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Purnia', 'Darbhanga', 'Bihar Sharif', 'Arrah', 'Begusarai', 'Katihar'],
        ),
        'chhattisgarh': StateInfo(
          name: 'Chhattisgarh',
          code: 'chhattisgarh',
          cities: ['Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg', 'Rajnandgaon', 'Raigarh', 'Jagdalpur'],
        ),
        'goa': StateInfo(
          name: 'Goa',
          code: 'goa',
          cities: ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa', 'Ponda', 'Bicholim'],
        ),
        'gujarat': StateInfo(
          name: 'Gujarat',
          code: 'gujarat',
          cities: ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar', 'Jamnagar', 'Junagadh', 'Gandhinagar', 'Anand', 'Nadiad', 'Morbi', 'Mehsana', 'Bharuch'],
        ),
        'haryana': StateInfo(
          name: 'Haryana',
          code: 'haryana',
          cities: ['Faridabad', 'Gurgaon', 'Panipat', 'Ambala', 'Yamunanagar', 'Rohtak', 'Hisar', 'Karnal', 'Sonipat', 'Panchkula'],
        ),
        'himachal_pradesh': StateInfo(
          name: 'Himachal Pradesh',
          code: 'himachal_pradesh',
          cities: ['Shimla', 'Dharamshala', 'Solan', 'Mandi', 'Palampur', 'Baddi', 'Nahan', 'Kullu', 'Manali'],
        ),
        'jharkhand': StateInfo(
          name: 'Jharkhand',
          code: 'jharkhand',
          cities: ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar', 'Hazaribagh', 'Giridih', 'Ramgarh'],
        ),
        'karnataka': StateInfo(
          name: 'Karnataka',
          code: 'karnataka',
          cities: ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum', 'Gulbarga', 'Davangere', 'Bellary', 'Shimoga', 'Tumkur', 'Udupi'],
        ),
        'kerala': StateInfo(
          name: 'Kerala',
          code: 'kerala',
          cities: ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Kollam', 'Alappuzha', 'Palakkad', 'Kannur', 'Kottayam', 'Malappuram'],
        ),
        'madhya_pradesh': StateInfo(
          name: 'Madhya Pradesh',
          code: 'madhya_pradesh',
          cities: ['Indore', 'Bhopal', 'Jabalpur', 'Gwalior', 'Ujjain', 'Sagar', 'Dewas', 'Satna', 'Ratlam', 'Rewa', 'Murwara', 'Singrauli'],
        ),
        'maharashtra': StateInfo(
          name: 'Maharashtra',
          code: 'maharashtra',
          cities: ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik', 'Aurangabad', 'Solapur', 'Kolhapur', 'Amravati', 'Navi Mumbai', 'Sangli', 'Malegaon', 'Akola', 'Latur', 'Ahmednagar'],
        ),
        'manipur': StateInfo(
          name: 'Manipur',
          code: 'manipur',
          cities: ['Imphal', 'Thoubal', 'Bishnupur', 'Churachandpur', 'Kakching'],
        ),
        'meghalaya': StateInfo(
          name: 'Meghalaya',
          code: 'meghalaya',
          cities: ['Shillong', 'Tura', 'Jowai', 'Nongstoin', 'Williamnagar'],
        ),
        'mizoram': StateInfo(
          name: 'Mizoram',
          code: 'mizoram',
          cities: ['Aizawl', 'Lunglei', 'Champhai', 'Serchhip', 'Kolasib'],
        ),
        'nagaland': StateInfo(
          name: 'Nagaland',
          code: 'nagaland',
          cities: ['Kohima', 'Dimapur', 'Mokokchung', 'Tuensang', 'Wokha'],
        ),
        'odisha': StateInfo(
          name: 'Odisha',
          code: 'odisha',
          cities: ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Brahmapur', 'Sambalpur', 'Puri', 'Balasore', 'Bhadrak', 'Baripada'],
        ),
        'punjab': StateInfo(
          name: 'Punjab',
          code: 'punjab',
          cities: ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda', 'Mohali', 'Pathankot', 'Hoshiarpur', 'Batala', 'Moga'],
        ),
        'rajasthan': StateInfo(
          name: 'Rajasthan',
          code: 'rajasthan',
          cities: ['Jaipur', 'Jodhpur', 'Kota', 'Bikaner', 'Ajmer', 'Udaipur', 'Bhilwara', 'Alwar', 'Bharatpur', 'Sikar', 'Sri Ganganagar', 'Pali'],
        ),
        'sikkim': StateInfo(
          name: 'Sikkim',
          code: 'sikkim',
          cities: ['Gangtok', 'Namchi', 'Gyalshing', 'Mangan', 'Rangpo'],
        ),
        'tamil_nadu': StateInfo(
          name: 'Tamil Nadu',
          code: 'tamil_nadu',
          cities: ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem', 'Tirunelveli', 'Tiruppur', 'Vellore', 'Erode', 'Thoothukudi', 'Dindigul', 'Thanjavur', 'Nagercoil'],
        ),
        'telangana': StateInfo(
          name: 'Telangana',
          code: 'telangana',
          cities: ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam', 'Ramagundam', 'Mahbubnagar', 'Nalgonda', 'Adilabad', 'Suryapet'],
        ),
        'tripura': StateInfo(
          name: 'Tripura',
          code: 'tripura',
          cities: ['Agartala', 'Udaipur', 'Dharmanagar', 'Kailashahar', 'Ambassa'],
        ),
        'uttar_pradesh': StateInfo(
          name: 'Uttar Pradesh',
          code: 'uttar_pradesh',
          cities: ['Lucknow', 'Kanpur', 'Ghaziabad', 'Agra', 'Varanasi', 'Meerut', 'Allahabad', 'Bareilly', 'Aligarh', 'Moradabad', 'Saharanpur', 'Gorakhpur', 'Noida', 'Firozabad', 'Jhansi', 'Muzaffarnagar', 'Mathura'],
        ),
        'uttarakhand': StateInfo(
          name: 'Uttarakhand',
          code: 'uttarakhand',
          cities: ['Dehradun', 'Haridwar', 'Roorkee', 'Haldwani', 'Rudrapur', 'Kashipur', 'Rishikesh', 'Nainital', 'Mussoorie'],
        ),
        'west_bengal': StateInfo(
          name: 'West Bengal',
          code: 'west_bengal',
          cities: ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri', 'Bardhaman', 'Malda', 'Baharampur', 'Habra', 'Kharagpur', 'Haldia'],
        ),
        'delhi': StateInfo(
          name: 'Delhi',
          code: 'delhi',
          cities: ['New Delhi', 'Delhi', 'Dwarka', 'Rohini', 'Pitampura', 'Janakpuri', 'Lajpat Nagar', 'Karol Bagh', 'Connaught Place'],
        ),
        'chandigarh': StateInfo(
          name: 'Chandigarh',
          code: 'chandigarh',
          cities: ['Chandigarh'],
        ),
        'puducherry': StateInfo(
          name: 'Puducherry',
          code: 'puducherry',
          cities: ['Puducherry', 'Karaikal', 'Mahe', 'Yanam'],
        ),
        'jammu_kashmir': StateInfo(
          name: 'Jammu & Kashmir',
          code: 'jammu_kashmir',
          cities: ['Srinagar', 'Jammu', 'Anantnag', 'Baramulla', 'Sopore', 'Kathua', 'Udhampur'],
        ),
        'ladakh': StateInfo(
          name: 'Ladakh',
          code: 'ladakh',
          cities: ['Leh', 'Kargil'],
        ),
      },
    ),
    'usa': CountryInfo(
      name: 'United States',
      code: 'usa',
      flag: '🇺🇸',
      states: {
        'california': StateInfo(
          name: 'California',
          code: 'california',
          cities: ['Los Angeles', 'San Francisco', 'San Diego', 'San Jose', 'Sacramento', 'Fresno', 'Oakland', 'Long Beach', 'Bakersfield', 'Anaheim'],
        ),
        'texas': StateInfo(
          name: 'Texas',
          code: 'texas',
          cities: ['Houston', 'San Antonio', 'Dallas', 'Austin', 'Fort Worth', 'El Paso', 'Arlington', 'Corpus Christi', 'Plano', 'Laredo'],
        ),
        'florida': StateInfo(
          name: 'Florida',
          code: 'florida',
          cities: ['Jacksonville', 'Miami', 'Tampa', 'Orlando', 'St. Petersburg', 'Hialeah', 'Tallahassee', 'Fort Lauderdale', 'Port St. Lucie', 'Cape Coral'],
        ),
        'new_york': StateInfo(
          name: 'New York',
          code: 'new_york',
          cities: ['New York City', 'Buffalo', 'Rochester', 'Yonkers', 'Syracuse', 'Albany', 'New Rochelle', 'Mount Vernon', 'Schenectady', 'Utica'],
        ),
        'illinois': StateInfo(
          name: 'Illinois',
          code: 'illinois',
          cities: ['Chicago', 'Aurora', 'Naperville', 'Joliet', 'Rockford', 'Springfield', 'Elgin', 'Peoria', 'Champaign', 'Waukegan'],
        ),
        'pennsylvania': StateInfo(
          name: 'Pennsylvania',
          code: 'pennsylvania',
          cities: ['Philadelphia', 'Pittsburgh', 'Allentown', 'Reading', 'Scranton', 'Bethlehem', 'Lancaster', 'Harrisburg', 'Erie', 'York'],
        ),
        'ohio': StateInfo(
          name: 'Ohio',
          code: 'ohio',
          cities: ['Columbus', 'Cleveland', 'Cincinnati', 'Toledo', 'Akron', 'Dayton', 'Parma', 'Canton', 'Youngstown', 'Lorain'],
        ),
        'georgia': StateInfo(
          name: 'Georgia',
          code: 'georgia',
          cities: ['Atlanta', 'Augusta', 'Columbus', 'Macon', 'Savannah', 'Athens', 'Sandy Springs', 'Roswell', 'Johns Creek', 'Albany'],
        ),
        'washington': StateInfo(
          name: 'Washington',
          code: 'washington',
          cities: ['Seattle', 'Spokane', 'Tacoma', 'Vancouver', 'Bellevue', 'Kent', 'Everett', 'Renton', 'Spokane Valley', 'Federal Way'],
        ),
        'arizona': StateInfo(
          name: 'Arizona',
          code: 'arizona',
          cities: ['Phoenix', 'Tucson', 'Mesa', 'Chandler', 'Scottsdale', 'Glendale', 'Gilbert', 'Tempe', 'Peoria', 'Surprise'],
        ),
      },
    ),
    'uk': CountryInfo(
      name: 'United Kingdom',
      code: 'uk',
      flag: '🇬🇧',
      states: {
        'england': StateInfo(
          name: 'England',
          code: 'england',
          cities: ['London', 'Birmingham', 'Manchester', 'Leeds', 'Liverpool', 'Sheffield', 'Bristol', 'Newcastle', 'Nottingham', 'Leicester', 'Brighton', 'Plymouth', 'Southampton', 'Reading', 'Derby'],
        ),
        'scotland': StateInfo(
          name: 'Scotland',
          code: 'scotland',
          cities: ['Glasgow', 'Edinburgh', 'Aberdeen', 'Dundee', 'Inverness', 'Perth', 'Stirling', 'Paisley'],
        ),
        'wales': StateInfo(
          name: 'Wales',
          code: 'wales',
          cities: ['Cardiff', 'Swansea', 'Newport', 'Wrexham', 'Barry', 'Neath', 'Cwmbran', 'Bridgend'],
        ),
        'northern_ireland': StateInfo(
          name: 'Northern Ireland',
          code: 'northern_ireland',
          cities: ['Belfast', 'Derry', 'Lisburn', 'Newtownabbey', 'Bangor', 'Craigavon', 'Newry'],
        ),
      },
    ),
    'canada': CountryInfo(
      name: 'Canada',
      code: 'canada',
      flag: '🇨🇦',
      states: {
        'ontario': StateInfo(
          name: 'Ontario',
          code: 'ontario',
          cities: ['Toronto', 'Ottawa', 'Mississauga', 'Brampton', 'Hamilton', 'London', 'Markham', 'Vaughan', 'Kitchener', 'Windsor'],
        ),
        'quebec': StateInfo(
          name: 'Quebec',
          code: 'quebec',
          cities: ['Montreal', 'Quebec City', 'Laval', 'Gatineau', 'Longueuil', 'Sherbrooke', 'Levis', 'Saguenay', 'Trois-Rivieres'],
        ),
        'british_columbia': StateInfo(
          name: 'British Columbia',
          code: 'british_columbia',
          cities: ['Vancouver', 'Surrey', 'Burnaby', 'Richmond', 'Victoria', 'Abbotsford', 'Coquitlam', 'Kelowna', 'Langley'],
        ),
        'alberta': StateInfo(
          name: 'Alberta',
          code: 'alberta',
          cities: ['Calgary', 'Edmonton', 'Red Deer', 'Lethbridge', 'St. Albert', 'Medicine Hat', 'Grande Prairie', 'Airdrie'],
        ),
        'manitoba': StateInfo(
          name: 'Manitoba',
          code: 'manitoba',
          cities: ['Winnipeg', 'Brandon', 'Steinbach', 'Thompson', 'Portage la Prairie'],
        ),
        'saskatchewan': StateInfo(
          name: 'Saskatchewan',
          code: 'saskatchewan',
          cities: ['Saskatoon', 'Regina', 'Prince Albert', 'Moose Jaw', 'Swift Current'],
        ),
      },
    ),
    'australia': CountryInfo(
      name: 'Australia',
      code: 'australia',
      flag: '🇦🇺',
      states: {
        'new_south_wales': StateInfo(
          name: 'New South Wales',
          code: 'new_south_wales',
          cities: ['Sydney', 'Newcastle', 'Wollongong', 'Central Coast', 'Maitland', 'Wagga Wagga', 'Albury', 'Port Macquarie', 'Tamworth'],
        ),
        'victoria': StateInfo(
          name: 'Victoria',
          code: 'victoria',
          cities: ['Melbourne', 'Geelong', 'Ballarat', 'Bendigo', 'Shepparton', 'Mildura', 'Warrnambool', 'Wodonga'],
        ),
        'queensland': StateInfo(
          name: 'Queensland',
          code: 'queensland',
          cities: ['Brisbane', 'Gold Coast', 'Sunshine Coast', 'Townsville', 'Cairns', 'Toowoomba', 'Mackay', 'Rockhampton'],
        ),
        'western_australia': StateInfo(
          name: 'Western Australia',
          code: 'western_australia',
          cities: ['Perth', 'Bunbury', 'Geraldton', 'Kalgoorlie', 'Albany', 'Mandurah'],
        ),
        'south_australia': StateInfo(
          name: 'South Australia',
          code: 'south_australia',
          cities: ['Adelaide', 'Mount Gambier', 'Whyalla', 'Murray Bridge', 'Port Augusta'],
        ),
        'tasmania': StateInfo(
          name: 'Tasmania',
          code: 'tasmania',
          cities: ['Hobart', 'Launceston', 'Devonport', 'Burnie'],
        ),
      },
    ),
    'germany': CountryInfo(
      name: 'Germany',
      code: 'germany',
      flag: '🇩🇪',
      states: {
        'bavaria': StateInfo(
          name: 'Bavaria',
          code: 'bavaria',
          cities: ['Munich', 'Nuremberg', 'Augsburg', 'Regensburg', 'Ingolstadt', 'Wurzburg', 'Erlangen'],
        ),
        'north_rhine_westphalia': StateInfo(
          name: 'North Rhine-Westphalia',
          code: 'north_rhine_westphalia',
          cities: ['Cologne', 'Dusseldorf', 'Dortmund', 'Essen', 'Duisburg', 'Bochum', 'Wuppertal', 'Bonn', 'Munster'],
        ),
        'baden_wurttemberg': StateInfo(
          name: 'Baden-Württemberg',
          code: 'baden_wurttemberg',
          cities: ['Stuttgart', 'Karlsruhe', 'Mannheim', 'Freiburg', 'Heidelberg', 'Ulm', 'Heilbronn'],
        ),
        'berlin': StateInfo(
          name: 'Berlin',
          code: 'berlin',
          cities: ['Berlin'],
        ),
        'hamburg': StateInfo(
          name: 'Hamburg',
          code: 'hamburg',
          cities: ['Hamburg'],
        ),
        'hesse': StateInfo(
          name: 'Hesse',
          code: 'hesse',
          cities: ['Frankfurt', 'Wiesbaden', 'Kassel', 'Darmstadt', 'Offenbach'],
        ),
      },
    ),
    'japan': CountryInfo(
      name: 'Japan',
      code: 'japan',
      flag: '🇯🇵',
      states: {
        'tokyo': StateInfo(
          name: 'Tokyo',
          code: 'tokyo',
          cities: ['Tokyo', 'Hachioji', 'Machida', 'Tachikawa', 'Musashino'],
        ),
        'osaka': StateInfo(
          name: 'Osaka',
          code: 'osaka',
          cities: ['Osaka', 'Sakai', 'Higashiosaka', 'Toyonaka', 'Suita', 'Takatsuki'],
        ),
        'kanagawa': StateInfo(
          name: 'Kanagawa',
          code: 'kanagawa',
          cities: ['Yokohama', 'Kawasaki', 'Sagamihara', 'Fujisawa', 'Yokosuka'],
        ),
        'aichi': StateInfo(
          name: 'Aichi',
          code: 'aichi',
          cities: ['Nagoya', 'Toyota', 'Okazaki', 'Ichinomiya', 'Kasugai'],
        ),
        'hokkaido': StateInfo(
          name: 'Hokkaido',
          code: 'hokkaido',
          cities: ['Sapporo', 'Asahikawa', 'Hakodate', 'Kushiro', 'Obihiro'],
        ),
        'fukuoka': StateInfo(
          name: 'Fukuoka',
          code: 'fukuoka',
          cities: ['Fukuoka', 'Kitakyushu', 'Kurume', 'Omuta', 'Iizuka'],
        ),
        'kyoto': StateInfo(
          name: 'Kyoto',
          code: 'kyoto',
          cities: ['Kyoto', 'Uji', 'Kameoka', 'Joyo', 'Nagaokakyo'],
        ),
      },
    ),
    'uae': CountryInfo(
      name: 'UAE',
      code: 'uae',
      flag: '🇦🇪',
      states: {
        'dubai': StateInfo(
          name: 'Dubai',
          code: 'dubai',
          cities: ['Dubai', 'Jebel Ali', 'Deira', 'Jumeirah'],
        ),
        'abu_dhabi': StateInfo(
          name: 'Abu Dhabi',
          code: 'abu_dhabi',
          cities: ['Abu Dhabi', 'Al Ain', 'Madinat Zayed'],
        ),
        'sharjah': StateInfo(
          name: 'Sharjah',
          code: 'sharjah',
          cities: ['Sharjah', 'Khor Fakkan', 'Kalba'],
        ),
        'ajman': StateInfo(
          name: 'Ajman',
          code: 'ajman',
          cities: ['Ajman', 'Masfout'],
        ),
        'ras_al_khaimah': StateInfo(
          name: 'Ras Al Khaimah',
          code: 'ras_al_khaimah',
          cities: ['Ras Al Khaimah', 'Al Jazirah Al Hamra'],
        ),
        'fujairah': StateInfo(
          name: 'Fujairah',
          code: 'fujairah',
          cities: ['Fujairah', 'Dibba'],
        ),
      },
    ),
    'singapore': CountryInfo(
      name: 'Singapore',
      code: 'singapore',
      flag: '🇸🇬',
      states: {
        'central': StateInfo(
          name: 'Central Region',
          code: 'central',
          cities: ['Singapore', 'Orchard', 'Marina Bay', 'Bugis', 'Chinatown'],
        ),
      },
    ),
  };

  /// Get all countries as a list
  static List<CountryInfo> get allCountries {
    return countries.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get country by code
  static CountryInfo? getCountry(String code) {
    return countries[code];
  }

  /// Get all states for a country
  static List<StateInfo> getStates(String countryCode) {
    final country = countries[countryCode];
    if (country == null) return [];
    return country.states.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get state by code
  static StateInfo? getState(String countryCode, String stateCode) {
    return countries[countryCode]?.states[stateCode];
  }

  /// Get cities for a state
  static List<String> getCities(String countryCode, String stateCode) {
    return countries[countryCode]?.states[stateCode]?.cities ?? [];
  }

  /// Search cities across all countries
  static List<CitySearchResult> searchCities(String query) {
    if (query.isEmpty) return [];
    
    final results = <CitySearchResult>[];
    final lowerQuery = query.toLowerCase();
    
    for (final countryEntry in countries.entries) {
      for (final stateEntry in countryEntry.value.states.entries) {
        for (final city in stateEntry.value.cities) {
          if (city.toLowerCase().contains(lowerQuery)) {
            results.add(CitySearchResult(
              city: city,
              stateCode: stateEntry.key,
              stateName: stateEntry.value.name,
              countryCode: countryEntry.key,
              countryName: countryEntry.value.name,
              flag: countryEntry.value.flag,
            ));
          }
        }
      }
    }
    
    return results;
  }
}

class CountryInfo {
  final String name;
  final String code;
  final String flag;
  final Map<String, StateInfo> states;

  const CountryInfo({
    required this.name,
    required this.code,
    required this.flag,
    required this.states,
  });
}

class StateInfo {
  final String name;
  final String code;
  final List<String> cities;

  const StateInfo({
    required this.name,
    required this.code,
    required this.cities,
  });
}

class CitySearchResult {
  final String city;
  final String stateCode;
  final String stateName;
  final String countryCode;
  final String countryName;
  final String flag;

  CitySearchResult({
    required this.city,
    required this.stateCode,
    required this.stateName,
    required this.countryCode,
    required this.countryName,
    required this.flag,
  });

  String get displayName => '$city, $stateName, $countryName $flag';
}

