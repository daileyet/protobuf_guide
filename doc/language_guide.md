# Language Guide

This protocol buffer language will base on proto2 version.

## Defining A Message Type

We need create a `.proto` file to define the message type.

```
message SearchRequest {
  required string query = 1;
  optional int32 page_number = 2;
  optional int32 result_per_page = 3;
}
```

### Specifying Field Types

In message `SearchRequest`, each field need field type. All scalar value types as below:

| .proto Type | Notes                                                                                                                                           | C++ Type | Java Type  | Python Type                          | Go Type  |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------- | ------------------------------------ | -------- |
| double      |                                                                                                                                                 | double   | double     | float                                | *float64 |
| float       |                                                                                                                                                 | float    | float      | float                                | *float32 |
| int32       | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead. | int32    | int        | int                                  | *int32   |
| int64       | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead. | int64    | long       | int/long                             | *int64   |
| uint32      | Uses variable-length encoding.                                                                                                                  | uint32   | int        | int/long                             | *uint32  |
| uint64      | Uses variable-length encoding.                                                                                                                  | uint64   | long       | int/long                             | *uint64  |
| sint32      | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.                            | int32    | int        | int                                  | *int32   |
| sint64      | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s.                            | int64    | long       | int/long                             | *int64   |
| fixed32     | Always four bytes. More efficient than uint32 if values are often greater than 228.                                                             | uint32   | int        | int/long                             | *uint32  |
| fixed64     | Always eight bytes. More efficient than uint64 if values are often greater than 256.                                                            | uint64   | long       | int/long                             | *uint64  |
| sfixed32    | Always four bytes.                                                                                                                              | int32    | int        | int                                  | *int32   |
| sfixed64    | Always eight bytes.                                                                                                                             | int64    | long       | int/long                             | *int64   |
| bool        | bool                                                                                                                                            | boolean  | bool       | *bool                                |
| string      | A string must always contain UTF-8 encoded or 7-bit ASCII text.                                                                                 | string   | String     | unicode (Python 2) or str (Python 3) | *string  |
| bytes       | May contain any arbitrary sequence of bytes.                                                                                                    | string   | ByteString | bytes                                | []byte   |

### Assigning Field Numbers

Each field in message definition has a **unique number**. This number is a identification for each field in message binary format.

Field number from 1 to 2<sup>29</sup>-1. This range [19000,19999] cannot used by ourself, because they are reserved by Protocol Buffers implementation

Once the field number be used in system, should not be change anymore.

> NOTE: \
> Field number 1 - 15 will take one byte in binary format \
> 16 - 2047 will take tow bytes

### Specifying Field Rules

* `required` must have and inintial, it will be forever
* `optional` optional, could be zero and unset
* `repeated` arrary of items

### Adding More Message Types

One or more message types can be defined in one `.proto` file.

```
message SearchRequest {
  required string query = 1;
  optional int32 page_number = 2;
  optional int32 result_per_page = 3;
}

message SearchResponse {
 ...
}
```

### Adding Comments

Like c/c++ style comments, we can use `//` and `/* */` to add comments in definition.

```
/* SearchRequest represents a search query, with pagination options to
 * indicate which results to include in the response. */
message SearchRequest {
  required string query = 1;
  optional int32 page_number = 2;  // Which page number do we want?
  optional int32 result_per_page = 3;  // Number of results to return per page.
}
```

### Reserved Fields

```
message Foo {
  reserved 2, 15, 9 to 11; // reserved field numbers
  reserved "foo", "bar"; // reserver field names
}
```

That's means in message `FOO`, you can't define field with number/name which in reserved 

### Generated From **.proto**

* C++ : `.h` and `.cc` for each `.proto` file
* Java: `.java` for each message type, special `Builder` classes for message creating.


## Optional Fields And Default Values

We can provide a default value for an optional field.

```
optional int32 result_per_page = 3 [default = 10];
```
scalar type-specific default value will be used when not specified default value for optional field.

| type    | default value       |
| ------- | ------------------- |
| string  | empty string        |
| bytes   | empty byte string   |
| bool    | false               |
| numeric | 0                   |
| enum    | first value in enum |


## Enumerations

```
message SearchRequest {
  required string query = 1;
  optional int32 page_number = 2;
  optional int32 result_per_page = 3 [default = 10];
  enum Corpus {
    UNIVERSAL = 0;
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
  }
  optional Corpus corpus = 4 [default = UNIVERSAL];
}
```


## Using Other Message Types

```
message SearchResponse {
  repeated Result result = 1;
}

message Result {
  required string url = 1;
  optional string title = 2;
  repeated string snippets = 3;
}
```

The above definition is include two message types. One message can refer to another message type as field directly.

### Importing Definitions

When above definition `Result` in a seperated `.proto` file, we should import this definition into `SearchResponse` definition file.

```
import "myproject/other_protos.proto";
```

When the import `.proto` file location is changed, we can do following step to avoid updating all called `.proto` files.

1. move old file to now location
2. create a dummy old file in old location
3. add `import public` with new file into import statement

```
// new.proto
// All definitions are moved here
```

```
// old.proto
// This is the proto that all clients are importing.
import public "new.proto";
import "other.proto";
```

```
// client.proto
import "old.proto";
// You use definitions from old.proto and new.proto, but not other.proto
```

## Nested Types

```
message SearchResponse {
  message Result {
    required string url = 1;
    optional string title = 2;
    repeated string snippets = 3;
  }
  repeated Result result = 1;
}
```

Useit in other outside message type:

```
message SomeOtherMessage {
  optional SearchResponse.Result result = 1;
}
```

multinest messgae type also can be done:

```
message Outer {       // Level 0
  message MiddleAA {  // Level 1
    message Inner {   // Level 2
      required int64 ival = 1;
      optional bool  booly = 2;
    }
  }
  message MiddleBB {  // Level 1
    message Inner {   // Level 2
      required int32 ival = 1;
      optional bool  booly = 2;
    }
  }
}
```

### Groups

```
message SearchResponse {
  repeated group Result = 1 {
    required string url = 2;
    optional string title = 3;
    repeated string snippets = 4;
  }
}
```

Group combines a nested message type and a field by single declaration.

The above example, define a field name `result`(lower-case of type name) with type `Result` in message type `SearchResponse`


## Updating A Message Type

If you want to update/modify already exist and used message type in `.proto` file, you should following the ruls as below:

1. Don't change existing filed number
2. Any new fields that you add should be optional or repeated
3. Non-required fields can be removed, as long as the field number is not used again in your updated message type
4. int32, uint32, int64, uint64, and bool are all compatible, can change to each other
5. sint32 and sint64 are compatible with each other but are not compatible with the other integer types
6. string and bytes are compatible as long as the bytes are valid UTF-8
7. Embedded messages are compatible with bytes if the bytes contain an encoded version of the message
8. fixed32 is compatible with sfixed32, and fixed64 with sfixed64
9. For string, bytes, and message fields, optional is compatible with repeated
10. Changing a default value is generally OK
11. enum is compatible with int32, uint32, int64, and uint64 in terms of wire format
12. In the current Java and C++ implementations, when unrecognized enum values are stripped out, they are stored along with other unknown fields
13. Changing a single optional value into a member of a new oneof is safe and binary compatible
14. Changing a field between a map<K, V> and the corresponding repeated message field is binary compatible


## Extensions

Declare a range of field numbers in a message type and lets third-party to extend/implement. \
It seems like parent/child class, but has a same and one class name in generated code.

```
// foo.proto
message Foo {
  // ...
  extensions 100 to 199; // reserved [100,199] field number for extendsions
}

```

```
// myfoo.proto
import "foo.proto";

extend Foo {
  optional int32 bar = 126;
}
````

The above code show a extendsion field in message `Foo`.

The generated code for `Foo` in `myfoo.proto` is same as original for those regular message fields. \
Those extension field will be accessed as below:

```c++
Foo foo;
foo.SetExtension(bar, 15);
```

> Note:  that extensions can be of any field type, including message types, but cannot be oneofs or maps.

### Nested Extensions

```
message Baz {
  extend Foo {
    optional int32 bar = 126;
  }
  ...
}
```

```c++
Foo foo;
foo.SetExtension(Baz::bar, 15);
```

We can do extension even as below:

```
message Baz {
  extend Foo {
    optional Baz foo_ext = 127;
  }
  ...
}
```

However, it is not recommend, we could do it as below:

```
message Baz {
  ...
}

// This can even be in a different file.
extend Foo {
  optional Baz foo_baz_ext = 127;
}
```


## Oneof

Like struct `Union` in C/C++. There will share memory, and at most one field can be set at the same time.

### Using Oneof

```
message SampleMessage {
  oneof test_oneof {
     string name = 4;
     SubMessage sub_message = 9;
  }
}
```

In `oneof` definition, cannot use the required, optional, or repeated keywords. \
 If you need to add a repeated field to a oneof, you can use a message containing the repeated field.


### Oneof Features

* Setting a oneof field will automatically clear all other members of the oneof.
```c++
SampleMessage message;
message.set_name("name");
CHECK(message.has_name());
message.mutable_sub_message();   // Will clear name field.
CHECK(!message.has_name());
```
* If the parser encounters multiple members of the same oneof on the wire, only the last member seen is used in the parsed message.
* Extensions are not supported for oneof.
* A oneof cannot be repeated.
* Reflection APIs work for oneof fields.
* If you set a oneof field to the default value (such as setting an int32 oneof field to 0), the "case" of that oneof field will be set, and the value will be serialized on the wire.
* If you're using C++, make sure your code doesn't cause memory crashes.
```c++
SampleMessage message;
SubMessage* sub_message = message.mutable_sub_message();
message.set_name("name");      // Will delete sub_message
sub_message->set_...            // Crashes here
```
* in C++, if you Swap() two messages with oneofs, each message will end up with the other’s oneof case
```c++
SampleMessage msg1;
msg1.set_name("name");
SampleMessage msg2;
msg2.mutable_sub_message();
msg1.swap(&msg2);
CHECK(msg1.has_sub_message());
CHECK(msg2.has_name());
```


## Map

```
map<key_type, value_type> map_field = N;
```

`key_type` can be any integral or string type (so, any scalar type except for floating point types and bytes). \
`value_type`  can be any type except another map.

```
map<string, Project> projects = 3;
````

### Maps Features

* Extensions are not supported for maps.
* Maps cannot be repeated, optional, or required.
* Wire format ordering and map iteration ordering of map values is undefined.
* When generating text format for a .proto, maps are sorted by key. Numeric keys are sorted numerically.
* When parsing from the wire or when merging, if there are duplicate map keys the last key seen is used. When parsing a map from text format, parsing may fail if there are duplicate keys.

### Backwards compatibility

The map syntax is equivalent to the following on the wire, so protocol buffers implementations that do not support maps can still handle your data:

```
message MapFieldEntry {
  optional key_type key = 1;
  optional value_type value = 2;
}

repeated MapFieldEntry map_field = N;
````


## Packages

```
package foo.bar;
message Open { ... }
```

```
message Foo {
  ...
  required foo.bar.Open open = 1;
  ...
}
```

* In C++ the generated classes are wrapped inside a C++ namespace. For example, Open would be in the namespace foo::bar.
* In Java, the package is used as the Java package, unless you explicitly provide a option java_package in your .proto file.



## Options

Individual declarations in a `.proto` file can be annotated with a number of options. Options do not change the overall meaning of a declaration, but may affect the way it is handled in a particular context.

Most commonly used options:

* `java_package` generated class package name
```
option java_package = "com.example.foo";
```
* `java_outer_classname` generated class name
```
option java_outer_classname = "Ponycopter";
```
* `optimize_for`
  * `SPEED` (default): Compiler will generate code for serializing, parsing, and performing other common operations on your message types. This code is highly optimized
  * `CODE_SIZE`: Compiler will generate minimal classes and will rely on shared, reflection-based code to implement serialialization, parsing, and various other operations.
  * `LITE_RUNTIME`: Compiler will generate classes that depend only on the "lite" runtime library (libprotobuf-lite instead of libprotobuf)
```
option optimize_for = CODE_SIZE;
```
* `packed` (field option): If set to true on a repeated field of a basic numeric type, a more compact encoding is used. 
```
repeated int32 samples = 4 [packed=true];
```
* `deprecated` (field option): If set to true, indicates that the field is deprecated and should not be used by new code.
```
optional int32 old_field = 6 [deprecated=true];
```


## Generating Your Classes

```
protoc --proto_path=_IMPORT_PATH_ --cpp_out=_DST_DIR_ --java_out=_DST_DIR_ --python_out=_DST_DIR_ _path/to/file_.proto
```

* `IMPORT_PATH` a directory in which to look for .proto files when resolving import directives.
* `--cpp_out` generates C++ code directory
* `--java_out` generates Java code directory
* `--python_out` generates Python code directory

