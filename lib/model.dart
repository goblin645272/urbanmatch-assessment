import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GitHubRepo {
  int? id;
  GithubCommit? lastCommit;
  String? name;
  String? fullName;
  bool? private;
  Owner? owner;
  int? forks;
  DateTime? updatedAt;
  int? openIssues;
  String? defaultBranch;

  GitHubRepo({
    this.id,
    this.lastCommit,
    this.name,
    this.fullName,
    this.private,
    this.owner,
    this.forks,
    this.updatedAt,
    this.openIssues,
    this.defaultBranch,
  });

  GitHubRepo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lastCommit = json['last_commit'] != null
        ? GithubCommit.fromJson(json['last_commit'])
        : null;
    name = json['name'];
    fullName = json['full_name'];
    updatedAt =
        json['updated_at'] != null ? DateTime.parse(json["updated_at"]) : null;
    private = json['private'];
    owner = json['owner'] != null ? Owner.fromJson(json['owner']) : null;
    forks = json['forks'];
    openIssues = json['open_issues'];
    defaultBranch = json['default_branch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['full_name'] = fullName;
    data['private'] = private;
    if (owner != null) {
      data['owner'] = owner!.toJson();
    }
    if (lastCommit != null) {
      data["last_commit"] = lastCommit!.toJson();
    }
    data['forks'] = forks;
    if (updatedAt != null) {
      data['updated_at'] = updatedAt!.toIso8601String();
    }
    data['open_issues'] = openIssues;
    data['default_branch'] = defaultBranch;
    return data;
  }
}

class Owner {
  String? avatarUrl;
  String? type;

  Owner({this.avatarUrl, this.type});

  Owner.fromJson(Map<String, dynamic> json) {
    avatarUrl = json['avatar_url'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar_url'] = avatarUrl;
    data['type'] = type;
    return data;
  }
}

Future<List<GitHubRepo>> fetchGithubRepolist(Uri url) async {
  final response = await http.get(url);
  return compute(parseUserlist, response.body);
}

List<GitHubRepo> parseUserlist(String responseBody) {
  var list = json.decode(responseBody) as List<dynamic>;

  var githubrepoList = list.map((model) => GitHubRepo.fromJson(model)).toList();
  return githubrepoList;
}

class GithubCommit {
  String? sha;
  Commit? commit;

  GithubCommit({this.sha, this.commit});

  GithubCommit.fromJson(Map<String, dynamic> json) {
    sha = json['sha'];
    commit = json['commit'] != null ? Commit.fromJson(json['commit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sha'] = sha;
    if (commit != null) {
      data['commit'] = commit!.toJson();
    }
    return data;
  }
}

class Commit {
  Committer? committer;
  String? message;

  Commit({this.committer, this.message});

  Commit.fromJson(Map<String, dynamic> json) {
    committer = json['committer'] != null
        ? Committer.fromJson(json['committer'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (committer != null) {
      data['committer'] = committer!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Committer {
  String? name;
  String? email;
  String? date;

  Committer({this.name, this.email, this.date});

  Committer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['date'] = date;
    return data;
  }
}

Future<GithubCommit> fetchGithubCommitlist(Uri url) async {
  final response = await http.get(url);
  return compute(parseLastRepoCommit, response.body);
}

GithubCommit parseLastRepoCommit(String responseBody) {
  var list = json.decode(responseBody) as List<dynamic>;
  var githubCommit = GithubCommit.fromJson(list[0]);
  return githubCommit;
}
