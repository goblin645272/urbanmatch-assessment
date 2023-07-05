import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urbanmatch/model.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  List<GitHubRepo> gitrepoList = [];

  DateFormat formatter = DateFormat('dd/MM/yy  hh:mm:ss');

  @override
  void initState() {
    parsedata();
    super.initState();
  }

  void parsedata() async {
    setState(() {
      _isLoading = true;
    });
    var value = await fetchGithubRepolist(
      Uri.parse(
        "https://api.github.com/users/freeCodeCamp/repos",
      ),
    );
    setState(() {
      gitrepoList.addAll(value);
      _isLoading = false;
    });

    // task 2 Asyncronous fetchting commits for each repositoy
    for (var repository in gitrepoList) {
      //Example commit link https://api.github.com/repos/freeCodeCamp/1password-teams-open-source/commits
      GithubCommit commitDetails = await fetchGithubCommitlist(
        Uri.parse(
          "https://api.github.com/repos/${repository.fullName}/commits",
        ),
      );
      repository.lastCommit = commitDetails;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.grey[850],
      body: _isLoading
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: gitrepoList.length,
              itemBuilder: (context, index) => ListTile(
                trailing: gitrepoList[index].lastCommit != null
                    ? IconButton(
                        onPressed: () => launchUrl(Uri.parse(
                            'https://github.com/${gitrepoList[index].fullName!}')),
                        icon: const Icon(
                          Icons.web,
                          color: Colors.white,
                        ),
                      )
                    : null,
                title: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              gitrepoList[index].name!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Row(
                              children: [
                                Icon(
                                  gitrepoList[index].private!
                                      ? Icons.lock
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                Text(
                                  gitrepoList[index].private!
                                      ? "Private"
                                      : "Public",
                                  style: const TextStyle(color: Colors.white),
                                )
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Last Updated at ${formatter.format(gitrepoList[index].updatedAt!)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Forks: ${gitrepoList[index].forks}",
                              style: const TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    gitrepoList[index].lastCommit != null
                        ? Text(
                            "Last Commit id: ${gitrepoList[index].lastCommit!.sha!.substring(0, 6)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )
                        : const Row(
                            children: [
                              Text(
                                "Fetching last commit...",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                  ],
                ),
              ),
            ),
    );
  }
}
