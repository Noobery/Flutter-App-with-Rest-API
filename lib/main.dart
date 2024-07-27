import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}
// ignore_for_file: avoid_print
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              children: [
                const Text(
                  "My First Application",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NextPage(
                                    email: emailController.text,
                                    password: passwordController.text)));
                      },
                      child: const Text('Login'));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class BlankPage extends StatefulWidget {
  const BlankPage({Key? key}) : super(key: key);

  @override
  State<BlankPage> createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  static const String apiUrl = '10.0.2.2:5001';
  dynamic courseDetails;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
  try {
    final Uri url = Uri.http(apiUrl, '/courses');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final dynamic body = json.decode(response.body);
      if (body['status'] == 'ok') {
        setState(() {
          courseDetails = body['Message'];
          isLoading = false; // Hide the loading indicator
        });
      } else {
        throw Exception('Failed to fetch courses: ${body['message']}');
      }
    } else {
      throw Exception('Failed to load details: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching course details: $e');
  }
}
Future<void> updateCourse(int courseId, String newCourseName) async {
  final Uri url = Uri.parse('http://10.0.2.2:5001/course/$courseId'); // Update the URI format

  final headers = {
    'Content-Type': 'application/json',
  };

  final requestBody = {
    'course': newCourseName,
  };

  try {
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Course updated successfully');
      
      // Update courseDetails list with the new course name
      setState(() {
        final updatedCourseIndex = courseDetails.indexWhere((course) => course['course_id'] == courseId);
        if (updatedCourseIndex != -1) {
          courseDetails[updatedCourseIndex]['course_name'] = newCourseName;
        }
      });
    } else {
      print('Failed to update course. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Course List & Edit'),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : courseDetails != null
            ? ListView.builder(
                itemCount: courseDetails.length,
                itemBuilder: (context, index) {
                  final course = courseDetails[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        'Course ID: ${course['course_id']}, Name: ${course['course_name']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          if (course != null && course['course_id'] != null && course['course_name'] != null) {
                            print('Edit button clicked for Course ID: ${course['course_id']}, Name: ${course['course_name']}');
                            String updatedCourseName = course['course_name'];
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Edit Course Name'),
                                  content: TextFormField(
                                    initialValue: course['course_name'],
                                    onChanged: (value) {
                                      updatedCourseName = value;
                                    },
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await updateCourse(course['course_id'], updatedCourseName);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            print('Error: Course details are null');
                          }
                        },
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text('No course details available'),
              ),
  );
}


}

class NextPage extends StatefulWidget {
  const NextPage({super.key, required this.email, required this.password});

  final String email;
  final String password;

  @override
  State<NextPage> createState() => _NextPageState();
}


class _NextPageState extends State<NextPage> {
  static const String apiUrl = '10.0.2.2:5001';
  dynamic courseDetails;
  bool isLoading = false;

  TextEditingController courseController = TextEditingController();
  TextEditingController deleteController = TextEditingController();

  Future<void> fetchcourseDetails() async {
    try {
      final Uri url = Uri.http(apiUrl, '/courses');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        if (body is Map<String, dynamic>) {
          setState(() {
            courseDetails = body;
          });

          print('courseDetails: $courseDetails');
          setState(() {
            isLoading = false; // Hide the loading indicator
          });
        } else {
          throw Exception('Invalid response format or status is not "ok"');
        }
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching replay details: $e');
    }
  }

  Future<void> addCourse(String courseName) async {
  final Uri url = Uri.http(apiUrl, '/course');
  final Map<String, String> requestBody = {
    'course': courseName,
  };

  final headers = {
    'Content-Type': 'application/json',
  };

  try {
    print('URL: $url');
    print('Headers: $headers');
    print('Request Body: ${json.encode(requestBody)}');

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Course added successfully');
    } else {
      print('Failed to add course. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  Future<void> deleteCourse(int courseId) async {
    final Uri url = Uri.http(apiUrl, '/course/$courseId');

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Course deleted successfully');
      } else {
        print('Failed to deleted course. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Delete Courses'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Add/Delete Courses'),
            Text('Email: ${widget.email}'),
            Text(('Password: ${widget.password}')),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlankPage()),
                );
              },
              child: const Text('Fetch Replay Details'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     fetchcourseDetails();
            //   },
            //   child: const Text('Fetch Replay Details'),
            // ),
            if (isLoading)
              const CircularProgressIndicator() // Show a loading indicator while fetching data
            else if (courseDetails != null)
              Card(
                child: ListTile(
                  title: const Text('Replay Data'), // You can customize this part
                  subtitle: Text(courseDetails
                      .toString()), // Display your fetched data here
                ),
              ),
            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                addCourse(courseController.text);
              },
              child: const Text('Add course'),
            ),
            TextField(
              controller: deleteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Delete Course',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                deleteCourse(int.tryParse(deleteController.text) ?? 0);
              },
              child: const Text('Delete course'),
            ),
          ],
        ),
      ),
    );
  }
}
