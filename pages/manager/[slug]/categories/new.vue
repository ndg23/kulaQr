<template>
  <ManagerCategoryForm :slug="String(route.params.slug)" :next-order="nextOrder" />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useSupabaseWrapper } from '~/composables/useSupabase'

definePageMeta({ layout: 'manager', middleware: 'auth' })

const route = useRoute()
const { client: supabase } = useSupabaseWrapper()
const nextOrder = ref(1)

// Ordre proposé : à la suite des catégories existantes
onMounted(async () => {
  const { count } = await supabase
    .from('categories')
    .select('id', { count: 'exact', head: true })
    .eq('establishment_id', route.params.slug as string)
  nextOrder.value = (count || 0) + 1
})
</script>
