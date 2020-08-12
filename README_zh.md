# Protobuf 快速指南

[English](./README.md) [Chinese](README_zh.md)

## 安装

基于Linux Unbutun平台上源码安装 [C++ Installation - Unix](https://github.com/protocolbuffers/protobuf/tree/master/src)

### 准备

```shell
sudo apt-get install autoconf automake libtool curl make g++ unzip
```

### 下载源码

```shell
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git submodule update --init --recursive
./autogen.sh
```

### 编译安装

```shell
 ./configure
 make
 make check
 sudo make install
 sudo ldconfig # refresh shared library cache.
```

## 教程

### 定义proto消息格式

[addressbook.proto](https://github.com/daileyet/protobuf_guide/blob/master/code/proto/addressbook.proto)

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

#### 生成目标代码

```shell
protoc -I=code/proto --cpp_out=code/c++ code/proto/addressbook.proto
```

It will genarate files: `addressbook.pb.h` and `addressbook.pb.cc` under `code/c++` .

#### 使用

[writemsg](https://github.com/daileyet/protobuf_guide/blob/master/code/c%2B%2B/writemsg.cpp)

[readmsg](https://github.com/daileyet/protobuf_guide/blob/master/code/c%2B%2B/readmsg.cpp)

##### 编译

```shell
g++ -std=c++11 code/c++/addressbook.pb.cc code/c++/writemsg.cpp -o code/c++/writemsg.out `pkg-config --cflags --libs protobuf`
```

```shell
g++ -std=c++11 code/c++/addressbook.pb.cc code/c++/readmsg.cpp -o code/c++/readmsg.out `pkg-config --cflags --libs protobuf`
```

##### 运行

```shell
./code/c++/writemsg.out code/c++/my.adr

./code/c++/readmsg.out code/c++/my.adr
```


### Java

#### 生成目标代码

```shell
protoc -I=code/proto --java_out=code/java code/proto/addressbook.proto
```

It will genarate files: `AddressBookProtos.java` under `code/java .

#### 使用

[AddPerson](code/java/AddPerson.java)

[ListPeople](code/java/ListPeople.java)

##### 安装 protobuf Java lib

1. 进入到 protobuf github源码下的 `java` 文件夹 
2. 在命令行下输入 `mvn clean install -DskipTests` 编译并安装protobuf java lib到本地
3. 从如下地址: `/home/<user>/.m2/repository/com/google/protobuf/protobuf-java/3.12.3/protobuf-java-3.12.3.jar` 获得库文件

##### 编译

```shell
javac -cp "/home/<user>/.m2/repository/com/google/protobuf/protobuf-java/3.12.3/protobuf-java-3.12.3.jar" code/java/com/example/tutorial/*.java
```

##### 运行

```shell
java -cp "code/java:/home/<user>/.m2/repository/com/google/protobuf/protobuf-java/3.12.3/protobuf-java-3.12.3.jar" com.example.tutorial.AddPerson my.adr


java -cp "code/java:/home/<user>/.m2/repository/com/google/protobuf/protobuf-java/3.12.3/protobuf-java-3.12.3.jar" com.example.tutorial.ListPeople my.adr
```

> 注意: java 运行命令 的classpath选项中多个路径的分割符在Linux下是 `:` 而在 Winodws下是 `;`