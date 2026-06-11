import React, { useState } from 'react';
import { View, Pressable, Linking } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import { TextField } from '@/presentation/ui/TextField';
import { Button } from '@/presentation/ui/Button';
import { useTheme } from '@/core/theme/useTheme';
import { useUseCases } from '@/di/useUseCases';
import type { SignInResult } from '@/domain/usecases/SignIn';

interface Props {
  onSignedIn: (result: SignInResult) => void;
}

// Sign in with the same fe4raccoons.com account. On success the web
// diagnostic's familiarity is imported so the phone never re-asks what the
// website already knows.
export function SignInStep({ onSignedIn }: Props) {
  const theme = useTheme();
  const uc = useUseCases();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const submit = async () => {
    if (busy || !email.trim() || !password) return;
    setBusy(true);
    setError(null);
    try {
      const result = await uc.signIn.execute({ email: email.trim(), password });
      onSignedIn(result);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Could not sign in. Try again.');
      setBusy(false);
    }
  };

  return (
    <View>
      <Text variant="h1">Welcome back</Text>
      <Text variant="sub" color={theme.palette.ink3} style={{ marginTop: 4 }}>
        Sign in with your fe4raccoons.com account. Your diagnostic and plan come with you.
      </Text>

      <View style={{ marginTop: 22, gap: 12 }}>
        <TextField
          testID="signin-email"
          value={email}
          onChangeText={setEmail}
          placeholder="Email"
          keyboardType="email-address"
        />
        <TextField
          testID="signin-password"
          value={password}
          onChangeText={setPassword}
          placeholder="Password"
          secureTextEntry
        />
      </View>

      <Pressable
        onPress={() => void Linking.openURL('https://fe4raccoons.com/login')}
        hitSlop={8}
        style={{ alignSelf: 'flex-end', marginTop: 12 }}
      >
        <Text variant="bodyStrong" color={theme.palette.ember}>
          Forgot password?
        </Text>
      </Pressable>

      {error ? (
        <Text variant="sub" color={theme.palette.error} style={{ marginTop: 12 }}>
          {error}
        </Text>
      ) : null}

      <View style={{ marginTop: 18 }}>
        <Button label={busy ? 'Signing in…' : 'Sign in'} onPress={() => void submit()} />
      </View>
    </View>
  );
}
