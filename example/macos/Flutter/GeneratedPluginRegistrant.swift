//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audioplayers_darwin
import path_provider_foundation
import record_macos
import voice_message_recorder

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioplayersDarwinPlugin.register(with: registry.registrar(forPlugin: "AudioplayersDarwinPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  RecordMacosPlugin.register(with: registry.registrar(forPlugin: "RecordMacosPlugin"))
  VoiceMessageRecorderPlugin.register(with: registry.registrar(forPlugin: "VoiceMessageRecorderPlugin"))
}
