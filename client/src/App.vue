<template>
  <v-app>
    <v-app-bar
      app
      color="indigo"
      dark
    >
      <div>
        <span style="font-weight: 500;">HackLab</span>
      </div>

      <v-spacer></v-spacer>

      <div>
        iHack Nebraska learning labs
      </div>
    </v-app-bar>

    <v-main>
      <v-container
        class="fill-height"
        fluid
      >
        <Home />
      </v-container>
    </v-main>

    <v-footer app>
      <span>&copy; {{ new Date().getFullYear() }}</span>
      <v-spacer></v-spacer>
      <div>
        Built for Hack Your School Club
      </div>
    </v-footer>
  </v-app>
</template>

<script lang="ts">
import { Vue, Component } from 'vue-property-decorator'
import Home from './views/Home.vue'

@Component({
  components: {
    Home,
  }
})
export default class App extends Vue {
  created() {
    this.$vuetify.theme.dark = true
  }
}
</script>
