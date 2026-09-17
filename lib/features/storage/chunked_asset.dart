import 'dart:typed_data';

/// Versioned authenticated chunk framing for bounded-memory vault I/O.
///
/// Each chunk is independently authenticated. [nonce] must be unique for the
/// data key and [tag] is the AEAD authentication tag. The storage layer must
/// verify a chunk before yielding any plaintext from it.
final class AuthenticatedChunk {
  const AuthenticatedChunk({
    required this.index,
    required this.nonce,
    required this.ciphertext,
    required this.tag,
    this.version = 1,
  });

  static const int nonceBytes = 12;
  static const int tagBytes = 16;
  static const int maxCiphertextBytes = 1024 * 1024;

  final int version;
  final int index;
  final Uint8List nonce;
  final Uint8List ciphertext;
  final Uint8List tag;

  bool get hasValidShape =>
      version == 1 &&
      index >= 0 &&
      nonce.length == nonceBytes &&
      tag.length == tagBytes &&
      ciphertext.isNotEmpty &&
      ciphertext.length <= maxCiphertextBytes;
}

/// Crypto implementation boundary. Native/platform-backed implementations must
/// use a maintained AEAD primitive and bind object identity + chunk index as
/// associated data. No unauthenticated plaintext may cross this boundary.
abstract interface class ChunkAead {
  Future<AuthenticatedChunk> encrypt({
    required String objectId,
    required int index,
    required Uint8List plaintext,
  });

  Future<Uint8List> decrypt({
    required String objectId,
    required AuthenticatedChunk chunk,
  });
}

/// Converts a source stream into bounded authenticated chunks without reading
/// the whole asset into memory.
Stream<AuthenticatedChunk> encryptBounded(
  Stream<List<int>> source,
  ChunkAead aead, {
  required String objectId,
}) async* {
  var index = 0;
  await for (final bytes in source) {
    if (bytes.isEmpty) continue;
    for (var offset = 0; offset < bytes.length; offset += AuthenticatedChunk.maxCiphertextBytes) {
      final end = (offset + AuthenticatedChunk.maxCiphertextBytes < bytes.length)
          ? offset + AuthenticatedChunk.maxCiphertextBytes
          : bytes.length;
      final plaintext = Uint8List.fromList(bytes.sublist(offset, end));
      final chunk = await aead.encrypt(objectId: objectId, index: index++, plaintext: plaintext);
      if (!chunk.hasValidShape) throw StateError('AEAD returned malformed chunk');
      yield chunk;
      plaintext.fillRange(0, plaintext.length, 0);
    }
  }
}
