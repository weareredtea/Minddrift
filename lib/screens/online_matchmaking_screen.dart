// lib/screens/online_matchmaking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/matchmaking_user.dart';
import '../providers/premium_provider.dart';
import '../l10n/app_localizations.dart';

class OnlineMatchmakingScreen extends StatefulWidget {
  static const routeName = '/online-matchmaking';
  
  const OnlineMatchmakingScreen({super.key});

  @override
  State<OnlineMatchmakingScreen> createState() => _OnlineMatchmakingScreenState();
}

class _OnlineMatchmakingScreenState extends State<OnlineMatchmakingScreen> {
  bool _isOnline = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeMatchmaking();
  }

  Future<void> _initializeMatchmaking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Create or update current user's matchmaking profile
    await _updateUserStatus(MatchmakingStatus.offline);
  }

  Future<void> _updateUserStatus(MatchmakingStatus status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final matchmakingUser = MatchmakingUser(
        id: '', // Will be set by Firestore
        userId: user.uid,
        displayName: user.displayName ?? AppLocalizations.of(context)!.anonymous,
        avatarUrl: user.photoURL,
        status: status,
        lastSeen: DateTime.now(),
        preferredBundles: ['bundle.free'], // Default to free bundle
        gamesPlayed: 0,
        averageScore: 0.0,
      );

      // Check if user already exists in matchmaking
      final existingDoc = await FirebaseFirestore.instance
          .collection('matchmaking_users')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        // Update existing user
        await FirebaseFirestore.instance
            .collection('matchmaking_users')
            .doc(existingDoc.docs.first.id)
            .update({
          'status': status.toString().split('.').last,
          'lastSeen': DateTime.now(),
          'displayName': user.displayName ?? 'Anonymous',
          'avatarUrl': user.photoURL,
        });
      } else {
        // Create new user
        await FirebaseFirestore.instance
            .collection('matchmaking_users')
            .add(matchmakingUser.toFirestore());
      }

      setState(() {
        _isOnline = status == MatchmakingStatus.online;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Future<void> _toggleOnlineStatus() async {
    setState(() => _isLoading = true);

    try {
      final newStatus = _isOnline ? MatchmakingStatus.offline : MatchmakingStatus.online;
      await _updateUserStatus(newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isOnline ? 'You are now offline' : 'You are now online'),
            backgroundColor: _isOnline ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createRoomWithUser(MatchmakingUser otherUser) async {
    setState(() => _isLoading = true);

    try {
      // Create a new room
      final roomData = {
        'createdAt': DateTime.now(),
        'status': 'waiting',
        'players': [
          {
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'name': FirebaseAuth.instance.currentUser!.displayName ?? 'Anonymous',
            'avatar': FirebaseAuth.instance.currentUser!.photoURL,
            'isHost': true,
            'isReady': true,
          },
          {
            'userId': otherUser.userId,
            'name': otherUser.displayName,
            'avatar': otherUser.avatarUrl,
            'isHost': false,
            'isReady': false,
          },
        ],
        'selectedBundle': 'bundle.free',
      };

      final roomRef = await FirebaseFirestore.instance
          .collection('rooms')
          .add(roomData);

      // Update both users' status to in-game
      await _updateUserStatus(MatchmakingStatus.inGame);
      
      // Update other user's status (this would normally be done via a notification)
      await FirebaseFirestore.instance
          .collection('matchmaking_users')
          .where('userId', isEqualTo: otherUser.userId)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('matchmaking_users')
              .doc(snapshot.docs.first.id)
              .update({
            'status': MatchmakingStatus.inGame.toString().split('.').last,
            'currentRoomId': roomRef.id,
          });
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room created with ${otherUser.displayName}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(roomRef.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create room: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    // Set user to offline when leaving
    _updateUserStatus(MatchmakingStatus.offline);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Online Matchmaking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, premium, child) {
          if (!premium.hasOnlineMatchmaking) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Premium Feature',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upgrade to Premium to play with random players',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(loc.upgradeToPremium),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Online status toggle
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _toggleOnlineStatus,
                        icon: Icon(_isOnline ? Icons.visibility_off : Icons.visibility),
                        label: Text(_isOnline ? 'Go Offline' : 'Go Online'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isOnline ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? 'Online - Looking for players' : 'Offline',
                      style: TextStyle(
                        color: _isOnline ? Colors.green : Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Online users list
              Expanded(
                child: _isOnline
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('matchmaking_users')
                            .where('status', isEqualTo: 'online')
                            .where('userId', isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error loading players: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final users = snapshot.data!.docs
                              .map((doc) => MatchmakingUser.fromFirestore(doc))
                              .toList();

                          if (users.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No players online',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Wait for other players to come online',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return _buildUserCard(user);
                            },
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.visibility_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Go Online to Find Players',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toggle the online status to start finding other players',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserCard(MatchmakingUser user) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 16),
                )
              : null,
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Games: ${user.gamesPlayed} • Avg Score: ${user.averageScore.toStringAsFixed(1)}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            Text(
              'Last seen: ${user.formattedLastSeen}',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: _isLoading ? null : () => _createRoomWithUser(user),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Play'),
        ),
      ),
    );
  }
}
