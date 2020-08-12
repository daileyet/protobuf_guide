# Protobuf quick guide

## Installtion

On Unbuntu, we can install protobuf from source code.

### Preparation

```shell
sudo apt-get install autoconf automake libtool curl make g++ unzip
```

### Download code

```shell
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git submodule update --init --recursive
./autogen.sh
```

### Compile&Install

```shell
 ./configure
 make
 make check
 sudo make install
 sudo ldconfig # refresh shared library cache.
```

## Tutorial

### Defining protocol format

[addressbook.proto](code/proto/addressbook.proto)
```
syntax = "proto2";

package tutorial;

// only for Java
option java_package = "com.example.tutorial";
option java_outer_classname = "AddressBookProtos";

message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    required string number = 1;
    optional PhoneType type = 2 [default = HOME];
  }

  repeated PhoneNumber phones = 4;
}

message AddressBook {
  repeated Person people = 1;
}
```

### C++

#### Compiling protocol format

```shell
protoc -I=code/proto --cpp_out=code/c++ code/proto/addressbook.proto
```

It will genarate files: `addressbook.pb.h` and `addressbook.pb.cc` under `code/c++` .

#### Usage

[writemsg](code/c++/writemsg.cpp)

[readmsg](code/c++/readmsg.cpp)

##### Compile

```shell
g++ -std=c++11 code/c++/addressbook.pb.cc code/c++/writemsg.cpp -o code/c++/writemsg.out `pkg-config --cflags --libs protobuf`
```

```shell
g++ -std=c++11 code/c++/addressbook.pb.cc code/c++/readmsg.cpp -o code/c++/readmsg.out `pkg-config --cflags --libs protobuf`
```

##### Run

```shell
./code/c++/writemsg.out code/c++/my.adr

./code/c++/readmsg.out code/c++/my.adr
```


### Java

#### Compiling protocol format

```shell
protoc -I=code/proto --java_out=code/java code/proto/addressbook.proto
```

It will genarate files: `AddressBookProtos.java` under `code/java .

#### Usage

[AddPerson](code/java/AddPerson.java)

[ListPeople](code/java/ListPeople.java)

##### Install protobuf Java lib

1. go to `java` folder under protobuf source folder
2. type `mvn clean install -DskipTests` to install into local system
3. get installed lib from `/home/<user>/.m2/repository/com/google/protobuf/protobuf-java/3.12.3/protobuf-java-3.12.3.jar`

##### Compile

```shell
javac -cp "/home/<user>/.m2/repository/com/google/protobuf/protobuf-java/3.12.3/protobuf-java-3.12.3.jar" code/java/com/example/tutorial/*.java
```

##### Run

```shell
java -cp "code/java:/home/<user>/.m2/repository/com/google/protobuf/protobuf-java/3.12.3/protobuf-java-3.12.3.jar" com.example.tutorial.AddPerson my.adr


java -cp "code/java:/home/<user>/.m2/repository/com/google/protobuf/protobuf-java/3.12.3/protobuf-java-3.12.3.jar" com.example.tutorial.ListPeople my.adr
```

> NOTE: separated token of classpath option is `:` in Linux and `;` in Window.