# Protobuf sample by CMake 

## Precondtion

installed cmake and protobuf

## Create sample files

### proto

create file `AddressBook.proto` at one folder such as `code`

```proto
package tutorial;

message Person{
    required string name=1;
    required int32 id=2;
    optional string email=3;

    enum PhoneType{
        MOBILE=0;
        HOME=1;
        WORK=2;
    }

    message PhoneNumber{
        required string number=1;
        optional PhoneType type=2 [default=HOME];
    }

    repeated PhoneNumber phone=4;
}

message AddressBook{
    repeated Person person=1;
}
```

### cpp

```c++
#include <iostream>
#include <fstream>
#include <vector>
#include "AddressBook.pb.h"

using namespace std;

void PromptForAddress(tutorial::Person* person) 
{
    cout << "Enter person ID number: ";
    int id;
    cin >> id;
    person->set_id(id);
    cin.ignore(256, '\n');
 
    cout << "Enter name: ";
    getline(cin, *person->mutable_name());
 
    cout << "Enter email address (blank for none): ";
    string email;
    getline(cin, email);
    if (!email.empty()) 
    {
        person->set_email(email);
    }
 
    while (true) 
    {
        cout << "Enter a phone number (or leave blank to finish): ";
        string number;
        getline(cin, number);
        if (number.empty()) 
        {
            break;
        }
 
        tutorial::Person::PhoneNumber* phone_number = person->add_phone();
        phone_number->set_number(number);
 
        cout << "Is this a mobile, home, or work phone? ";
        string type;
        getline(cin, type);
        if (type == "mobile") 
        {
            phone_number->set_type(tutorial::Person::MOBILE);
        } 
        else if (type == "home") 
        {
            phone_number->set_type(tutorial::Person::HOME);
        }
         else if (type == "work") 
         {
            phone_number->set_type(tutorial::Person::WORK);
        }
        else 
        {
            cout << "Unknown phone type.  Using default." << endl;
        }
    }
}
 
 
int main(int argc, char *argv[])
{
    GOOGLE_PROTOBUF_VERIFY_VERSION;
 
    if (argc != 2) 
    {
        cerr << "Usage:  " << argv[0] << " ADDRESS_BOOK_FILE" << endl;
        return -1;
    }
 
    tutorial::AddressBook address_book;
 
    {
    // Read the existing address book.
    fstream input(argv[1], ios::in | ios::binary);
    if (!input) {
      cout << argv[1] << ": File not found.  Creating a new file." << endl;
    } else if (!address_book.ParseFromIstream(&input)) {
      cerr << "Failed to parse address book." << endl;
      return -1;
    }
    }
 
    // Add an address.
    PromptForAddress(address_book.add_person());
 
    {
    // Write the new address book back to disk.
    fstream output(argv[1], ios::out | ios::trunc | ios::binary);
    if (!address_book.SerializeToOstream(&output)) {
      cerr << "Failed to write address book." << endl;
      return -1;
    }
    }
 
    // Optional:  Delete all global objects allocated by libprotobuf.
    google::protobuf::ShutdownProtobufLibrary();
 
    return 0;
}
```

### cmake file

```cmake
cmake_minimum_required(VERSION 3.0)
PROJECT(addrbktest)
SET(SRC_LIST main.cpp)

find_package(Protobuf REQUIRED)
if(PROTOBUF_FOUND)
    message(STATUS "protobuf libary found")
else()
    message(FATAL_ERROR "protobuf library is needed but can't be found")
endif()

include_directories(${PROTOBUF_INCLUDE_DIRS})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})
# generate pb.h、pb.cc
PROTOBUF_GENERATE_CPP(PROTO_SRCS PROTO_HDRS AddressBook.proto)

ADD_EXECUTABLE(addrbktest ${SRC_LIST} ${PROTO_SRCS} ${PROTO_HDRS})

target_link_libraries(addrbktest ${PROTOBUF_LIBRARIES})
```

## Build

create `build` folder under `code` folder.

```shell
makedir build && cd build
cmake .. && make
```

## Run

```shell
cd build && ./addrbktest test.db
```

