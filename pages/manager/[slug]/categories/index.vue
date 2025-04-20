<template>
  <div class="min-h-screen bg-gray-50">
    <ManagerHeader :establishment="establishment" />
    
    <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="bg-white shadow rounded-lg p-6">
        <div class="flex justify-between items-center mb-6">
          <h1 class="text-2xl font-semibold">Catégories</h1>
          <button
            @click="showAddCategory = true"
            class="btn-primary"
          >
            Ajouter une catégorie
          </button>
        </div>

        <!-- Categories List -->
        <draggable
          v-model="categories"
          @end="updateOrder"
          item-key="id"
          handle=".handle"
          class="space-y-2"
        >
          <template #item="{ element: category }">
            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center">
                <Icon
                  name="grip-vertical"
                  class="handle cursor-move text-gray-400 mr-3"
                />
                <span class="font-medium">{{ category.name }}</span>
              </div>
              <div class="flex items-center space-x-2">
                <button @click="editCategory(category)">
                  <Icon name="pencil" class="text-gray-500" />
                </button>
                <button @click="deleteCategory(category.id)">
                  <Icon name="trash" class="text-red-500" />
                </button>
              </div>
            </div>
          </template>
        </draggable>
      </div>
    </div>

    <!-- Modals -->
    <CategoryModal
      v-if="showAddCategory"
      :category="editingCategory"
      @close="closeModal"
      @save="saveCategory"
    />
  </div>
</template>

<script setup lang="ts">
// ... category management logic
</script> 