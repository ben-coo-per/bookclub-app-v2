<script lang="ts">
	import { page } from '$app/stores';
	import Icon from '@iconify/svelte';
	import type { Session } from '@supabase/supabase-js';
	import { createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();

	export let closeMenu = () => {};
	export let session: Session | null;
	export let deferredPWAPrompt: ({ prompt: () => void } & Event) | undefined;

	$: displayName = session?.user.user_metadata?.display_name;
	$: email = session?.user.email;
</script>

<div class="flex flex-col justify-between p-4 pt-10 h-full text-surface-900-50-token md:w-64">
	<ul class="flex flex-col gap-4 text-2xl">
		<li>
			<a
				href="/"
				class={`flex flex-row items-center gap-1 ${$page.url.pathname == '/' && 'font-bold'}`}
				on:click={closeMenu}
			>
				<Icon icon="lucide:messages-square" class="w-7 h-7" />
				Messages
			</a>
		</li>
		<li>
			<a
				href="/meetings"
				class={`flex flex-row items-center gap-1 ${
					$page.url.pathname == '/meetings' && 'font-bold'
				}`}
				on:click={closeMenu}
			>
				<Icon icon="lucide:calendar" class="w-7 h-7" />
				Meetings
			</a>
		</li>
	</ul>

	<div id="bottom" class="flex flex-col gap-4">
		<!-- <div class="bg-surface-50-900-token p-2 rounded-md shadow-lg">
			<div class="flex flex-row justify-between items-center">
				<h3 class="text-lg font-bold uppercase text-surface-800-100-token">🚧 Coming soon</h3>
				<a href="https://github.com/bencooper96/bookclub-app-v2" target="_blank" rel="noopener">
					<Icon icon="lucide:github" class="w-5 h-5" />
				</a>
			</div>
			<hr />
			<ul class="flex flex-col gap-1 text-xl mt-1">
				<li>
					<span class="flex flex-row items-center gap-1 opacity-50">
						<Icon icon="lucide:book-copy" class="w-7 h-7" />
						Reading history
					</span>
				</li>
				<li>
					<span class="flex flex-row items-center gap-1 opacity-50">
						<Icon icon="lucide:calendar-clock" class="w-7 h-7" />
						Attendance
					</span>
				</li>
				<li>
					<span class="flex flex-row items-center gap-1 opacity-50">
						<Icon icon="lucide:calendar" class="w-7 h-7" />
						Schedule
					</span>
				</li>
			</ul>
		</div> -->
		{#if deferredPWAPrompt !== undefined}
			<button
				class="sm:hidden flex flex-row items-center gap-2 px-4 py-2 text-sm rounded-sm shadow bg-primary-300-600-token text-surface-800"
				on:click={() => dispatch('install-pwa')}
			>
				Install App</button
			>
		{/if}
		<ul class="flex flex-col gap-4">
			<li>
				<a
					href="/add/book"
					class={`flex flex-row items-center gap-1 ${
						$page.url.pathname == '/add/book' && 'font-bold'
					}`}
					on:click={closeMenu}
				>
					<Icon icon="lucide:book-plus" class="w-7 h-7" />
					Add a book
				</a>
			</li>
			<li>
				<a
					href="/meetings/add"
					class={`flex flex-row items-center gap-1 ${
						$page.url.pathname == '/add/meeting' && 'font-bold'
					}`}
					on:click={closeMenu}
				>
					<Icon icon="lucide:calendar-plus" class="w-7 h-7" />
					Add a meeting
				</a>
			</li>
			<hr />
			<li>
				<a href={session ? '/profile' : '/auth/login'} on:click={closeMenu}>
					<div class="py-4 px-2 border border-surface-700-200-token rounded flex-row gap-2 flex">
						<Icon icon="mdi:account-circle" class="w-6 h-6" />
						<span>{session ? displayName ?? email : 'Sign In'}</span>
					</div>
				</a>
			</li>
		</ul>
	</div>
</div>
