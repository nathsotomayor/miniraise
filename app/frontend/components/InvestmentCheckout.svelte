<script>
  import { onMount, tick } from 'svelte'
  import OfferingSummary from './OfferingSummary.svelte'

  let { offeringId } = $props()

  let offering = $state(null)
  let status = $state('loading') // 'loading' | 'loaded' | 'error'
  let statusMessage = $state('')
  let heading

  async function load() {
    status = 'loading'
    statusMessage = ''
    try {
      const response = await fetch(`/api/offerings/${offeringId}`, { headers: { Accept: 'application/json' } })
      if (!response.ok) throw new Error(`Unexpected status ${response.status}`)
      offering = await response.json()
      status = 'loaded'
    } catch {
      status = 'error'
      statusMessage = 'This offering could not be loaded. Check your connection, then try again.'
    }
  }

  async function retry() {
    await load()
    await tick()
    heading.focus()
  }

  onMount(load)
</script>

<section aria-busy={status === 'loading'}>
  <h1 bind:this={heading} tabindex="-1">
    {#if status === 'loaded'}
      {offering.name}
    {:else if status === 'error'}
      Offering unavailable
    {:else}
      <span class="visually-hidden">Loading offering</span>
      <span class="skeleton" style:width="12ch" aria-hidden="true"></span>
    {/if}
  </h1>

  <p class="status" class:error={status === 'error'} role="status">{statusMessage}</p>

  {#if status === 'error'}
    <button type="button" onclick={retry}>Try again</button>
  {:else}
    <OfferingSummary offering={status === 'loaded' ? offering : null} />
  {/if}
</section>

<style>
  h1 {
    margin: 0;
    font-size: var(--font-size-xl);
    line-height: var(--line-height-tight);
  }

  h1:focus {
    outline: none;
  }

  h1:focus-visible {
    outline: var(--focus-ring);
    outline-offset: 2px;
  }

  .status {
    margin: var(--space-4) 0 0;
  }

  /* Stays in the accessibility tree while empty so screen readers announce new messages. */
  .status:empty {
    margin: 0;
  }

  .status.error {
    color: var(--color-error);
  }

  button {
    min-height: var(--touch-target-min);
    margin-top: var(--space-4);
    padding: var(--space-2) var(--space-6);
    font: inherit;
    font-weight: 600;
    color: var(--color-on-accent);
    background: var(--color-accent);
    border: 0;
    border-radius: var(--radius-md);
    cursor: pointer;
  }
</style>
