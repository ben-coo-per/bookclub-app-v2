<script lang="ts">
	// The ordering of these imports is critical to your app working properly
	import '../theme.postcss';
	// If you have source.organizeImports set to true in VSCode, then it will auto change this ordering
	import '@skeletonlabs/skeleton/styles/skeleton.css';
	// Most of your app wide CSS should be put in this file
	import '../app.postcss';

	import { invalidate } from '$app/navigation';
	import { onMount } from 'svelte';
	import { AppBar, Toast } from '@skeletonlabs/skeleton';
	import { computePosition, autoUpdate, offset, shift, flip, arrow } from '@floating-ui/dom';
	import { pwaInfo } from 'virtual:pwa-info';
	import { storePopup } from '@skeletonlabs/skeleton';
	import SideMenu from '$components/SideMenu.svelte';
	import DrawerMenu from '$components/DrawerMenu.svelte';
	import Icon from '@iconify/svelte';

	export let data;

	let { supabase, session, route } = data;
	$: ({ supabase, session, route } = data);
	storePopup.set({ computePosition, autoUpdate, offset, shift, flip, arrow });

	onMount(() => {
		const {
			data: { subscription }
		} = supabase.auth.onAuthStateChange((event, _session) => {
			if (_session?.expires_at !== session?.expires_at) {
				invalidate('supabase:auth');
			}
		});

		return () => subscription.unsubscribe();
	});

	$: webManifestLink = pwaInfo ? pwaInfo.webManifest.linkTag : '';
	// This variable will save the event for later use.
	let deferredPrompt: ({ prompt: () => void } & Event) | undefined;

	onMount(() => {
		window.addEventListener('beforeinstallprompt', (e) => {
			e.preventDefault();
			deferredPrompt = e as { prompt: () => void } & Event;
		});
	});

	function installApp() {
		deferredPrompt?.prompt();
	}

	type RouteOptions = {
		title: string;
		noMargin?: boolean;
		trailActions: TrailAction[];
	};

	type TrailAction = {
		icon?: string;
		href?: string;
		onClick?: () => void;
		text?: string;
	};

	const PATHS: Record<NonNullable<typeof route>, RouteOptions> = {
		'/': { title: 'Messages', noMargin: true, trailActions: [] },
		'/add/book': { title: 'Add Book or Reading', trailActions: [] },
		'/auth/login': { title: '', trailActions: [] },
		'/auth/sign-up': { title: '', trailActions: [] },
		'/profile': { title: 'Profile', trailActions: [] },
		'/meetings': {
			title: 'Meetings',
			trailActions: [{ text: 'Add meeting', icon: 'mdi:calendar-plus', href: '/meetings/add' }]
		},
		'/meetings/add': { title: 'Add Meeting', trailActions: [] },
		'/meetings/edit/[id]': { title: 'Edit Meeting', trailActions: [] }
	};

	const BACKGROUND_COLORS = ['#ff00f2', '#739AFF', '#F88D8D', '#39D4D4', '#BA48FF'];
	onMount(() => {
		// Set the background by randomly selecting from bg options
		const color = BACKGROUND_COLORS[Math.floor(Math.random() * BACKGROUND_COLORS.length)];
		const gradient = `radial-gradient(at 95% 16%, hsla(189, 100%, 80%, 1) 0px, transparent 50%),
		radial-gradient(at 80% 100%, hsla(248, 100%, 80%, 1) 0px, transparent 50%),
		radial-gradient(at 19% 96%, hsla(233, 100%, 80%, 1) 0px, transparent 50%),
		radial-gradient(at 29% 16%, hsla(304, 100%, 80%, 1) 0px, transparent 50%)`;

		document.body.style.background = color;
		document.body.style.backgroundImage = gradient;
		document.body.style.backgroundRepeat = 'no-repeat';
		document.body.style.backgroundAttachment = 'fixed';
	});
</script>

<svelte:head>
	{@html webManifestLink}
</svelte:head>
<div class="h-full flex flex-col">
	<AppBar class="fixed top-0 w-full h-16 z-40 md:hidden">
		<svelte:fragment slot="lead">
			<DrawerMenu {session} />
			<h1 class="ml-1 text-xl">{route ? PATHS[route].title : ''}</h1>
		</svelte:fragment>

		<svelte:fragment slot="trail">
			{#if route && PATHS[route]?.trailActions}
				{#each PATHS[route].trailActions as action}
					<a class="btn variant-filled btn-sm" href={action.href} on:click={action.onClick}>
						{#if action.icon}
							<Icon icon={action.icon} class="w-6 h-6" />
						{/if}
						{action.text}
					</a>
				{/each}
			{/if}
		</svelte:fragment>
	</AppBar>
	<div
		class="flex flex-row h-full mt-12 md:mt-0"
		class:mt-0={route ? PATHS[route].noMargin : false}
	>
		<div class="md:block hidden bg-surface-50-900-token shadow-lg">
			<SideMenu {session} deferredPWAPrompt={deferredPrompt} on:install-pwa={installApp} />
		</div>
		<div class="relative flex-1 w-full">
			<slot />
		</div>
	</div>
</div>
<Toast />

{#await import('$lib/ReloadPrompt.svelte') then { default: ReloadPrompt }}
	<ReloadPrompt />
{/await}
