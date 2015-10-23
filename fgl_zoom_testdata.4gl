#
#       (c) Copyright 2011, Four Js AsiaPac - www.4js.com.au/local
#
#       MIT License (http://www.opensource.org/licenses/mit-license.php)
#
#       Permission is hereby granted, free of charge, to any person
#       obtaining a copy of this software and associated documentation
#       files (the "Software"), to deal in the Software without restriction,
#       including without limitation the rights to use, copy, modify, merge,
#       publish, distribute, sublicense, and/or sell copies of the Software,
#       and to permit persons to whom the Software is furnished to do so,
#       subject to the following conditions:
#
#       The above copyright notice and this permission notice shall be
#       included in all copies or substantial portions of the Software.
#
#       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#       EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#       OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#       NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
#       BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
#       ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#       CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#       THE SOFTWARE.
#
#       fgl_zoom_testdata.4gl
#
#       January 2011 Reuben Barclay reuben@4js.com.au

#+ Create test data for use with the fgl_zoom test program
#+
#+ Provides a means to create 5 test programs for use with the fgl_zoom test
#+ program, populate them with data, and truncate, and drop them 


IMPORT util
IMPORT FGL fgldialog


         
FUNCTION create()
   TRY
      CREATE TABLE fgl_zoom_test(
         id INTEGER,
         desc CHAR(20),
         date_created DATE,
         time_created DATETIME HOUR TO SECOND,
         price DECIMAL(11,2),
         quantity DECIMAL(11,2)
      )

      CREATE TABLE fgl_zoom_state(
         state_code CHAR(2),
         state_name CHAR(15)
      )


      CREATE TABLE fgl_zoom_country(
         country_code INTEGER,
         country_2letter CHAR(2),
         country_3letter CHAR(3),
         country_name CHAR(30)
      )

      -- Based on the customer table from Four Js tutorial data
      CREATE TABLE fgl_zoom_store(
         store_num     INTEGER not null,
         store_name    CHAR(20) not null,
         addr          CHAR(20),
         addr2         CHAR(20),
         city          CHAR(15),
         state         CHAR(2),
         zipcode       CHAR(5),
         contact_name  CHAR(30),
         phone         CHAR(18)
      )

      -- Based on the customer table from Informix demo data
      CREATE TABLE fgl_zoom_customer
        (
        customer_num            integer,
        fname                   char(15),
        lname                   char(15),
        company                 char(20),
        address1                char(20),
        address2                char(20),
        city                    char(15),
        state                   char(2),
        zipcode                 char(5),
        phone                   char(18)
      )

   CATCH
      DISPLAY SQLCA.sqlcode
      DISPLAY SQLCA.sqlerrm
      DISPLAY SQLERRMESSAGE
      RETURN FALSE
   END TRY
   RETURN TRUE
END FUNCTION

PRIVATE FUNCTION drop()
DEFINE ok BOOLEAN

   LET ok = TRUE
   WHENEVER ANY ERROR CONTINUE
   DROP TABLE fgl_zoom_test
   LET ok = (STATUS==0) AND ok
   DROP TABLE fgl_zoom_state
   LET ok = (STATUS==0) AND ok
   DROP TABLE fgl_zoom_country
   LET ok = (STATUS==0) AND ok
   DROP TABLE fgl_zoom_store
   LET ok = (STATUS==0) AND ok
   DROP TABLE fgl_zoom_customer
   LET ok = (STATUS==0) AND ok
   WHENEVER ANY ERROR STOP
   RETURN ok
END FUNCTION

 FUNCTION populate()
   TRY
      CALL populate_fgl_zoom_test()
      CALL populate_fgl_zoom_country()
      CALL populate_fgl_zoom_state()
      CALL populate_fgl_zoom_store()
      CALL populate_fgl_zoom_customer()
   CATCH
      DISPLAY SQLCA.sqlcode
      DISPLAY SQLCA.sqlerrm
      DISPLAY SQLERRMESSAGE
      RETURN FALSE
   END TRY
   RETURN TRUE
END FUNCTION

PRIVATE FUNCTION truncate()

   TRY 
      TRUNCATE TABLE fgl_zoom_test
      TRUNCATE TABLE fgl_zoom_state
      TRUNCATE TABLE fgl_zoom_country
      TRUNCATE TABLE fgl_zoom_store
      TRUNCATE TABLE fgl_zoom_customer
      
   CATCH
      RETURN FALSE
   END TRY
   RETURN TRUE
END FUNCTION



PRIVATE FUNCTION populate_fgl_zoom_test()
DEFINE i, j INTEGER
DEFINE id INTEGER
DEFINE DESC CHAR(30)
DEFINE date_created DATE
DEFINE time_created DATETIME HOUR TO SECOND
DEFINE price, quantity DECIMAL(11,2)
DEFINE sb base.StringBuffer
   WHENEVER ANY ERROR RAISE

   FOR i = 1 TO 1000
      LET id = i
      LET sb = base.StringBuffer.create()
      CALL sb.append(ASCII(util.Math.rand(26)+65))
      FOR j = util.Math.rand(10)+4 TO 1 STEP -1
         CALL sb.append(ASCII(util.Math.rand(26)+97))
      END FOR
      LET desc = sb.toString()
      LET date_created = TODAY - util.Math.rand(730)
      LET time_created = SFMT("%1:%2:%3", util.Math.rand(24) USING "&&", util.Math.rand(60) USING "&&", util.Math.rand(60) USING "&&")
      LET price = util.Math.rand(100000)/100
      LET quantity = util.Math.rand(100000)/100

      INSERT INTO fgl_zoom_test (id, desc, date_created, time_created, price, quantity)
      VALUES(id, desc, date_created, time_created, price, quantity)
   END FOR
END FUNCTION

PRIVATE FUNCTION populate_fgl_zoom_state()
   WHENEVER ANY ERROR RAISE
   &define insert_state(p1,p2) INSERT INTO fgl_zoom_state VALUES (#p1, #p2)
   insert_state(AK,Alaska)
   insert_state(HI,Hawaii)
   insert_state(CA,California)
   insert_state(OR,Oregon)
   insert_state(WA,Washington)
   insert_state(ID,Idaho)
   insert_state(NV,Nevada)
   insert_state(MT,Montana)
   insert_state(WY,Wyoming)
   insert_state(UT,Utah)
   insert_state(AZ,Arizona)
   insert_state(NM,New Mexico)
   insert_state(CO,Colorado)
   insert_state(ND,North Dakota)
   insert_state(SD,South Dakota)
   insert_state(NE,Nebraska)
   insert_state(KS,Kansas)
   insert_state(OK,Oklahoma)
   insert_state(TX,Texas)
   insert_state(MN,Minnesota)
   insert_state(IA,Iowa)
   insert_state(MO,Missouri)
   insert_state(AR,Arkansas)
   insert_state(LA,Louisiana)
   insert_state(WI,Wisconsin)
   insert_state(IL,Illinois)
   insert_state(MS,Mississippi)
   insert_state(AL,Alabama)
   insert_state(FL,Florida)
   insert_state(GA,Georgia)
   insert_state(SC,South Carolina)
   insert_state(NC,North Carolina)
   insert_state(TN,Tennessee)
   insert_state(KY,Kentucky)
   insert_state(VA,Virginia)
   insert_state(WV,West Virginia)
   insert_state(MD,Maryland)
   insert_state(IN,Indiana)
   insert_state(MI,Michigan)
   insert_state(OH,Ohio)
   insert_state(PA,Pennsylvania)
   insert_state(DE,Delaware)
   insert_state(NJ,New Jersey)
   insert_state(NY,New York)
   insert_state(CT,Connecticut)
   insert_state(VT,Vermont)
   insert_state(RI,Rhode Island)
   insert_state(MA,Massachusetts)
   insert_state(NH,New Hampshire)
   insert_state(ME,Maine)
   insert_state(DC,D.C.)
   insert_state(PR,Puerto Rico)
   &undef insert_state
END FUNCTION

PRIVATE FUNCTION populate_fgl_zoom_country()
   WHENEVER ANY ERROR RAISE

   #TODO check code values, may have inadvertently lost a digit when adding quotes
   &define insert_country(p1,p2,p3,p4) INSERT INTO fgl_zoom_country VALUES(p4, p2, p3, p1)
   insert_country("Afghanistan","AF","AFG",004)
   insert_country("Aland Islands","AX","ALA",248)
   insert_country("Albania","AL","ALB",008)
   insert_country("Algeria","DZ","DZA",012)
   insert_country("American Samoa","AS","ASM",016)
   insert_country("Andorra","AD","AND",020)
   insert_country("Angola","AO","AGO",024)
   insert_country("Anguilla","AI","AIA",660)
   insert_country("Antarctica","AQ","ATA",010)
   insert_country("Antigua and Barbuda","AG","ATG",028)
   insert_country("Argentina","AR","ARG",032)
   insert_country("Armenia","AM","ARM",051)
   insert_country("Aruba","AW","ABW",533)
   insert_country("Australia","AU","AUS",036)
   insert_country("Austria","AT","AUT",040)
   insert_country("Azerbaijan","AZ","AZE",031)
   insert_country("Bahamas","BS","BHS",044)
   insert_country("Bahrain","BH","BHR",048)
   insert_country("Bangladesh","BD","BGD",050)
   insert_country("Barbados","BB","BRB",052)
   insert_country("Belarus","BY","BLR",112)
   insert_country("Belgium","BE","BEL",056)
   insert_country("Belize","BZ","BLZ",84)
   insert_country("Benin","BJ","BEN",04)
   insert_country("Bermuda","BM","BMU",60)
   insert_country("Bhutan","BT","BTN",64)
   insert_country("Bolivia","BO","BOL",68)
   insert_country("Bonaire, Saint Eustatius AND Saba","BQ","BES",35)
   insert_country("Bosnia AND Herzegovina","BA","BIH",70)
   insert_country("Botswana","BW","BWA",72)
   insert_country("Bouvet Island","BV","BVT",74)
   insert_country("Brazil","BR","BRA",76)
   insert_country("British Indian Ocean Territory","IO","IOT",86)
   insert_country("Brunei Darussalam","BN","BRN",96)
   insert_country("Bulgaria","BG","BGR",100)
   insert_country("Burkina Faso","BF","BFA",854)
   insert_country("Burundi","BI","BDI",108)
   insert_country("Cambodia","KH","KHM",116)
   insert_country("Cameroon","CM","CMR",120)
   insert_country("Canada","CA","CAN",124)
   insert_country("Cape Verde","CV","CPV",132)
   insert_country("Cayman Islands","KY","CYM",136)
   insert_country("Central African Republic","CF","CAF",140)
   insert_country("Chad","TD","TCD",148)
   insert_country("Chile","CL","CHL",152)
   insert_country("China","CN","CHN",156)
   insert_country("Christmas Island","CX","CXR",162)
   insert_country("Cocos \(Keeling\) Islands","CC","CCK",16)
   insert_country("Colombia","CO","COL",170)
   insert_country("Comoros","KM","COM",174)
   insert_country("Congo","CG","COG",178)
   insert_country("Congo, the Democratic Republic of the","CD","COD",180)
   insert_country("Cook Islands","CK","COK",184)
   insert_country("Costa Rica","CR","CRI",188)
   insert_country("Cote d\'Ivoire","CI","CIV",384)
   insert_country("Croatia","HR","HRV",191)
   insert_country("Cuba","CU","CUB",192)
   insert_country("Curacao","CW","CUW",31)
   insert_country("Cyprus","CY","CYP",196)
   insert_country("Czech Republic","CZ","CZE",03)
   insert_country("Denmark","DK","DNK",08)
   insert_country("Djibouti","DJ","DJI",62)
   insert_country("Dominica","DM","DMA",12)
   insert_country("Dominican Republic","DO","DOM",14)
   insert_country("Ecuador","EC","ECU",18)
   insert_country("Egypt","EG","EGY",818)
   insert_country("El Salvador","SV","SLV",22)
   insert_country("Equatorial Guinea","GQ","GNQ",26)
   insert_country("Eritrea","ER","ERI",32)
   insert_country("Estonia","EE","EST",33)
   insert_country("Ethiopia","ET","ETH",31)
   insert_country("Falkland Islands \(Malvinas\)","FK","FLK",38)
   insert_country("Faroe Islands","FO","FRO",34)
   insert_country("Fiji","FJ","FJI",42)
   insert_country("Finland","FI","FIN",46)
   insert_country("France","FR","FRA",0)
   insert_country("French Guiana","GF","GUF",4)
   insert_country("French Polynesia","PF","PYF",8)
   insert_country("French Southern Territories","TF","ATF",60)
   insert_country("Gabon","GA","GAB",66)
   insert_country("Gambia","GM","GMB",70)
   insert_country("Georgia","GE","GEO",68)
   insert_country("Germany","DE","DEU",76)
   insert_country("Ghana","GH","GHA",88)
   insert_country("Gibraltar","GI","GIB",92)
   insert_country("Greece","GR","GRC",300)
   insert_country("Greenland","GL","GRL",304)
   insert_country("Grenada","GD","GRD",308)
   insert_country("Guadeloupe","GP","GLP",312)
   insert_country("Guam","GU","GUM",316)
   insert_country("Guatemala","GT","GTM",320)
   insert_country("Guernsey","GG","GGY",831)
   insert_country("Guinea","GN","GIN",324)
   insert_country("Guinea-Bissau","GW","GNB",624)
   insert_country("Guyana","GY","GUY",328)
   insert_country("Haiti","HT","HTI",332)
   insert_country("Heard Island and McDonald Islands","HM","HMD",334)
   insert_country("Holy See, (Vatican City State)","VA","VAT",336)
   insert_country("Honduras","HN","HND",340)
   insert_country("Hong Kong","HK","HKG",344)
   insert_country("Hungary","HU","HUN",348)
   insert_country("Iceland","IS","ISL",352)
   insert_country("India","IN","IND",356)
   insert_country("Indonesia","ID","IDN",360)
   insert_country("Iran, Islamic Republic of","IR","IRN",364)
   insert_country("Iraq","IQ","IRQ",368)
   insert_country("Ireland","IE","IRL",372)
   insert_country("Isle of Man","IM","IMN",833)
   insert_country("Israel","IL","ISR",376)
   insert_country("Italy","IT","ITA",380)
   insert_country("Jamaica","JM","JAM",388)
   insert_country("Japan","JP","JPN",392)
   insert_country("Jersey","JE","JEY",832)
   insert_country("Jordan","JO","JOR",400)
   insert_country("Kazakhstan","KZ","KAZ",398)
   insert_country("Kenya","KE","KEN",404)
   insert_country("Kiribati","KI","KIR",96)
   insert_country("Korea, Democratic People\'s Republic of","KP","PRK",408)
   insert_country("Korea, Republic of","KR","KOR",410)
   insert_country("Kuwait","KW","KWT",414)
   insert_country("Kyrgyzstan","KG","KGZ",417)
   insert_country("Lao People\'s Democratic Republic","LA","LAO",418)
   insert_country("Latvia","LV","LVA",428)
   insert_country("Lebanon","LB","LBN",422)
   insert_country("Lesotho","LS","LSO",426)
   insert_country("Liberia","LR","LBR",430)
   insert_country("Libyan Arab Jamahiriya","LY","LBY",434)
   insert_country("Liechtenstein","LI","LIE",438)
   insert_country("Lithuania","LT","LTU",440)
   insert_country("Luxembourg","LU","LUX",442)
   insert_country("Macao","MO","MAC",446)
   insert_country("Macedonia, the former Yugoslav Republic of","MK","MKD",807)
   insert_country("Madagascar","MG","MDG",450)
   insert_country("Malawi","MW","MWI",454)
   insert_country("Malaysia","MY","MYS",458)
   insert_country("Maldives","MV","MDV",462)
   insert_country("Mali","ML","MLI",466)
   insert_country("Malta","MT","MLT",470)
   insert_country("Marshall Islands","MH","MHL",84)
   insert_country("Martinique","MQ","MTQ",474)
   insert_country("Mauritania","MR","MRT",478)
   insert_country("Mauritius","MU","MUS",480)
   insert_country("Mayotte","YT","MYT",175)
   insert_country("Mexico","MX","MEX",484)
   insert_country("Micronesia, Federated States of","FM","FSM",83)
   insert_country("Moldova, Republic of","MD","MDA",498)
   insert_country("Monaco","MC","MCO",492)
   insert_country("Mongolia","MN","MNG",496)
   insert_country("Montenegro","ME","MNE",499)
   insert_country("Montserrat","MS","MSR",00)
   insert_country("Morocco","MA","MAR",04)
   insert_country("Mozambique","MZ","MOZ",08)
   insert_country("Myanmar","MM","MMR",104)
   insert_country("Namibia","NA","NAM",16)
   insert_country("Nauru","NR","NRU",20)
   insert_country("Nepal","NP","NPL",24)
   insert_country("Netherlands","NL","NLD",28)
   insert_country("New Caledonia","NC","NCL",40)
   insert_country("New Zealand","NZ","NZL",54)
   insert_country("Nicaragua","NI","NIC",58)
   insert_country("Niger","NE","NER",62)
   insert_country("Nigeria","NG","NGA",66)
   insert_country("Niue","NU","NIU",70)
   insert_country("Norfolk Island","NF","NFK",74)
   insert_country("Northern Mariana Islands","MP","MNP",80)
   insert_country("Norway","NO","NOR",78)
   insert_country("Oman","OM","OMN",12)
   insert_country("Pakistan","PK","PAK",86)
   insert_country("Palau","PW","PLW",85)
   insert_country("Palestinian Territory, Occupied","PS","PSE",75)
   insert_country("Panama","PA","PAN",91)
   insert_country("Papua New Guinea","PG","PNG",98)
   insert_country("Paraguay","PY","PRY",600)
   insert_country("Peru","PE","PER",604)
   insert_country("Philippines","PH","PHL",608)
   insert_country("Pitcairn","PN","PCN",612)
   insert_country("Poland","PL","POL",616)
   insert_country("Portugal","PT","PRT",620)
   insert_country("Puerto Rico","PR","PRI",630)
   insert_country("Qatar","QA","QAT",634)
   insert_country("Reunion","RE","REU",638)
   insert_country("Romania","RO","ROU",642)
   insert_country("Russian Federation","RU","RUS",643)
   insert_country("Rwanda","RW","RWA",646)
   insert_country("Saint Barthelemy","BL","BLM",652)
   insert_country("Saint Helena, Ascension AND Tristan da Cunha","SH","SHN",654)
   insert_country("Saint Kitts and Nevis","KN","KNA",659)
   insert_country("Saint Lucia","LC","LCA",662)
   insert_country("Saint Martin (French part)","MF","MAF",663)
   insert_country("Saint Pierre and Miquelon","PM","SPM",666)
   insert_country("Saint Vincent and the Grenadines","VC","VCT",670)
   insert_country("Samoa","WS","WSM",882)
   insert_country("San Marino","SM","SMR",674)
   insert_country("Sao Tome AND Principe","ST","STP",678)
   insert_country("Saudi Arabia","SA","SAU",682)
   insert_country("Senegal","SN","SEN",686)
   insert_country("Serbia","RS","SRB",688)
   insert_country("Seychelles","SC","SYC",690)
   insert_country("Sierra Leone","SL","SLE",694)
   insert_country("Singapore","SG","SGP",702)
   insert_country("Sint Maarten (Dutch part)","SX","SXM",34)
   insert_country("Slovakia","SK","SVK",703)
   insert_country("Slovenia","SI","SVN",705)
   insert_country("Solomon Islands","SB","SLB",90)
   insert_country("Somalia","SO","SOM",706)
   insert_country("South Africa","ZA","ZAF",710)
   insert_country("South Georgia and the South Sandwich Islands","GS","SGS",39)
   insert_country("Spain","ES","ESP",724)
   insert_country("Sri Lanka","LK","LKA",144)
   insert_country("Sudan","SD","SDN",736)
   insert_country("Suriname","SR","SUR",740)
   insert_country("Svalbard and Jan Mayen","SJ","SJM",744)
   insert_country("Swaziland","SZ","SWZ",748)
   insert_country("Sweden","SE","SWE",752)
   insert_country("Switzerland","CH","CHE",756)
   insert_country("Syrian Arab Republic","SY","SYR",760)
   insert_country("Taiwan, Province of China","TW","TWN",158)
   insert_country("Tajikistan","TJ","TJK",762)
   insert_country("Tanzania, United Republic of","TZ","TZA",834)
   insert_country("Thailand","TH","THA",764)
   insert_country("Timor-Leste","TL","TLS",626)
   insert_country("Togo","TG","TGO",768)
   insert_country("Tokelau","TK","TKL",772)
   insert_country("Tonga","TO","TON",776)
   insert_country("Trinidad and Tobago","TT","TTO",780)
   insert_country("Tunisia","TN","TUN",788)
   insert_country("Turkey","TR","TUR",792)
   insert_country("Turkmenistan","TM","TKM",795)
   insert_country("Turks and Caicos Islands","TC","TCA",796)
   insert_country("Tuvalu","TV","TUV",798)
   insert_country("Uganda","UG","UGA",800)
   insert_country("Ukraine","UA","UKR",804)
   insert_country("United Arab Emirates","AE","ARE",784)
   insert_country("United Kingdom","GB","GBR",826)
   insert_country("United States","US","USA",840)
   insert_country("United States, Minor Outlying Islands","UM","UMI",81)
   insert_country("Uruguay","UY","URY",858)
   insert_country("Uzbekistan","UZ","UZB",860)
   insert_country("Vanuatu","VU","VUT",48)
   insert_country("Venezuela, Bolivarian Republic of","VE","VEN",862)
   insert_country("Viet Nam","VN","VNM",704)
   insert_country("Virgin Islands, British","VG","VGB",92)
   insert_country("Virgin Islands, U.S.","VI","VIR",850)
   insert_country("Wallis AND Futuna","WF","WLF",876)
   insert_country("Western Sahara","EH","ESH",732)
   insert_country("Yemen","YE","YEM",887)
   insert_country("Zambia","ZM","ZMB",894)
   insert_country("Zimbabwe","ZW","ZWE",716)



   &undef insert_country
END FUNCTION



PRIVATE FUNCTION populate_fgl_zoom_store()
   WHENEVER ANY ERROR RAISE

   INSERT INTO fgl_zoom_store VALUES (101,"Bandy\'s Hardware","110 Main","","Chicago","IL","60068","Bob Bandy","630-221-9055");
   INSERT INTO fgl_zoom_store VALUES (102,"The FIX-IT Shop","65W Elm Street Sqr.","","Madison","WI","65454","","630-34343434");
   INSERT INTO fgl_zoom_store VALUES (103,"Hill\'s Hobby Shop","553 Central Parkway","","Eau Claire","WI","54354","Janice Hilstrom","666-4564564");
   INSERT INTO fgl_zoom_store VALUES (104,"Illinois Hardware","123 Main Street","","Peoria","IL","63434","Ramon Aguirra","630-3434334");
   INSERT INTO fgl_zoom_store VALUES (105,"Tools and Stuff","645W Center Street","","Dubuque","IA","54654","Lavonne Robinson","630-4533456");
   INSERT INTO fgl_zoom_store VALUES (106,"TrueTest Hardware","6123 N. Michigan Ave","","Chicago","IL","60104","Michael Mazukelli","640-3453456");
   INSERT INTO fgl_zoom_store VALUES (202,"Fourth Ill Hardware","6123 N. Michigan Ave","","Chicago","IL","60104","Michael Mazukelli","640-3453456");
   INSERT INTO fgl_zoom_store VALUES (203,"2nd Hobby Shop","553 Central Parkway","","Eau Claire","WI","54354","Janice Hilstrom","666-4564564");
   INSERT INTO fgl_zoom_store VALUES (204,"2nd Hardware","123 Main Street","","Peoria","IL","63434","Ramon Aguirra","630-3434334"); 
   INSERT INTO fgl_zoom_store VALUES (205,"2nd Stuff","645W Center Street","","Dubuque","IA","54654","Lavonne Robinson","630-4533456");
   INSERT INTO fgl_zoom_store VALUES (206,"2ndTest Hardware","6123 N. Michigan Ave","","Chicago","IL","60104","Michael Mazukelli","640-3453456");
   INSERT INTO fgl_zoom_store VALUES (302,"Third FIX-IT Shop","65W Elm Street Sqr.","","Madison","WI","65454","","630-34343434");
   INSERT INTO fgl_zoom_store VALUES (303,"Third Hobby Shop","553 Central Parkway","","Eau Claire","WI","54354","Janice Hilstrom","666-4564564");
   INSERT INTO fgl_zoom_store VALUES (304,"Third IL Hardware","123 Main Street","","Peoria","IL","63434","Ramon Aguirra","630-3434334");
   INSERT INTO fgl_zoom_store VALUES (305,"Third and Stuff","645W Center Street","","Dubuque","IA","54654","Lavonne Robinson","630-4533456");
   INSERT INTO fgl_zoom_store VALUES (306,"Third Hardware","6123 N. Michigan Ave","","Chicago","IL","60104","Michael Mazukelli","640-3453456");
END FUNCTION

PRIVATE FUNCTION populate_fgl_zoom_customer()
   WHENEVER ANY ERROR RAISE

   INSERT INTO fgl_zoom_customer VALUES (101,"Ludwig","Pauli","All Sports Supplies","213 Erstwild Court","","Sunnyvale","CA","94086","408-789-8075")
   INSERT INTO fgl_zoom_customer VALUES (102,"Carole","Sadler","Sports Spot","785 Geary St","","San Francisco","CA","94117","415-822-1289")
   INSERT INTO fgl_zoom_customer VALUES (103,"Philip","Currie","Phil's Sports","654 Poplar","P. O. Box 3498","Palo Alto","CA","94303","415-328-4543")
   INSERT INTO fgl_zoom_customer VALUES (104,"Anthony","Higgins","Play Ball!","East Shopping Cntr.","422 Bay Road","Redwood City","CA","94026","415-368-1100")
   INSERT INTO fgl_zoom_customer VALUES (105,"Raymond","Vector","Los Altos Sports","1899 La Loma Drive","","Los Altos","CA","94022","415-776-3249")
   INSERT INTO fgl_zoom_customer VALUES (106,"George","Watson","Watson \& Son","1143 Carver Place","","Mountain View","CA","94063","415-389-8789")
   INSERT INTO fgl_zoom_customer VALUES (107,"Charles","Ream","Athletic Supplies","41 Jordan Avenue","","Palo Alto","CA","94304","415-356-9876")
   INSERT INTO fgl_zoom_customer VALUES (108,"Donald","Quinn","Quinn's Sports","587 Alvarado","","Redwood City","CA","94063","415-544-8729")
   INSERT INTO fgl_zoom_customer VALUES (109,"Jane","Miller","Sport Stuff","Mayfair Mart","7345 Ross Blvd.","Sunnyvale","CA","94086","408-723-8789")
   INSERT INTO fgl_zoom_customer VALUES (110,"Roy","Jaeger","AA Athletics","520 Topaz Way","","Redwood City","CA","94062","415-743-3611")
   INSERT INTO fgl_zoom_customer VALUES (111,"Frances","Keyes","Sports Center","3199 Sterling Court","","Sunnyvale","CA","94085","408-277-7245")
   INSERT INTO fgl_zoom_customer VALUES (112,"Margaret","Lawson","Runners & Others","234 Wyandotte Way","","Los Altos","CA","94022","415-887-7235")
   INSERT INTO fgl_zoom_customer VALUES (113,"Lana","Beatty","Sportstown","654 Oak Grove","","Menlo Park","CA","94025","415-356-9982")
   INSERT INTO fgl_zoom_customer VALUES (114,"Frank","Albertson","Sporting Place","947 Waverly Place","","Redwood City","CA","94062","415-886-6677")
   INSERT INTO fgl_zoom_customer VALUES (115,"Alfred","Grant","Gold Medal Sports","776 Gary Avenue","","Menlo Park","CA","94025","415-356-1123")
   INSERT INTO fgl_zoom_customer VALUES (116,"Jean","Parmelee","Olympic City","1104 Spinosa Drive","","Mountain View","CA","94040","415-534-8822")
   INSERT INTO fgl_zoom_customer VALUES (117,"Arnold","Sipes","Kids Korner","850 Lytton Court","","Redwood City","CA","94063","415-245-4578")
   INSERT INTO fgl_zoom_customer VALUES (118,"Dick","Baxter","Blue Ribbon Sports","5427 College","","Oakland","CA","94609","415-655-0011")
   INSERT INTO fgl_zoom_customer VALUES (119,"Bob","Shorter","The Triathletes Club","2405 Kings Highway","","Cherry Hill","NJ","08002","609-663-6079")
   INSERT INTO fgl_zoom_customer VALUES (120,"Fred","Jewell","Century Pro Shop","6627 N. 17th Way","","Phoenix","AZ","85016","602-265-8754")
   INSERT INTO fgl_zoom_customer VALUES (121,"Jason","Wallack","City Sports","Lake Biltmore Mall","350 W. 23rd Street","Wilmington","DE","19898","302-366-7511")
   INSERT INTO fgl_zoom_customer VALUES (122,"Cathy","O'Brian","The Sporting Life","543 Nassau Street","","Princeton","NJ","08540","609-342-0054")
   INSERT INTO fgl_zoom_customer VALUES (123,"Marvin","Hanlon","Bay Sports","10100 Bay Meadows Road","Suite 1020","Jacksonville","FL","32256","904-823-4239")
   INSERT INTO fgl_zoom_customer VALUES (124,"Chris","Putnum","Putnum's Putters","4715 S.E. Adams Blvd.","Suite 909C","Bartlesville","OK","74006","918-355-2074")
   INSERT INTO fgl_zoom_customer VALUES (125,"James","Henry","Total Fitness Sports","1450 Commonwealth Avenue","","Brighton","MA","02135","617-232-4159")
   INSERT INTO fgl_zoom_customer VALUES (126,"Eileen","Neelie","Neelie's Discount Sporting Goods","2539 South Utica Street","","Denver","CO","80219","303-936-7731")
   INSERT INTO fgl_zoom_customer VALUES (127,"Kim","Satifer","Big Blue Bike Shop","Blue Island Square","12222 Gregory Street","Blue Island","NY","60406","312-944-5691")
   INSERT INTO fgl_zoom_customer VALUES (128,"Frank","Lessor","Phoenix University","Athletic Department","1817 N. Thomas Road","Phoenix","AZ","85008","602-533-1817")

END FUNCTION

FUNCTION testdata_created()
DEFINE result BOOLEAN

   -- If the select statement executes with no error
   WHENEVER ANY ERROR CONTINUE
   SELECT COUNT(*) FROM fgl_zoom_test
   WHENEVER ANY ERROR STOP
   LET result = (STATUS==0)
   RETURN result
END FUNCTION
