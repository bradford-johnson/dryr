pacman::p_load(tidyverse,
               magick,
               patchwork,
               rvest,
               ggpath,
               showtext,
               htmltools,
               shiny,
               shinyjs,
               shinydashboard,
               gridExtra
)

showtext_auto()
showtext_opts(dpi = 300)

font_add_google(name = "Roboto", family = "Roboto")

font <- "Roboto"

get_logo <- function(group_id, link_prefix = "https://pleasehelpmyschool.com/groups/images/", link_suffix = ".jpg") {
  if (is.character(group_id)) {
    group_id = tolower(group_id)
    full_link <- paste0(link_prefix, group_id, link_suffix)
    return(full_link)
  } else {
    stop("Input is not a character string.")
  }
}

get_qr_code <- function(group_id, qr_prefix = "https://pleasehelpmyschool.com/shopping/sponsor/qrcodes/", qr_suffix = ".png"){
  if (is.character(group_id)) {
    group_id = toupper(group_id)
    qr_link <- paste0(qr_prefix, group_id, qr_suffix)
    return(qr_link)
  } else {
    stop("Input is not a character string.")
  }
}

get_group_url <- function(group_id, url_prefix = "https://pleasehelpmyschool.com/"){
  if (is.character(group_id)) {
    group_id = toupper(group_id)
    url = paste0(url_prefix, group_id)
    return(url)
  } else {
    stop("Input is not a character string.")
  }
}

get_group_name <- function(url) {
  webpage <- read_html(url)
  group_name_element <- webpage %>% html_node("h1")
  if (!is.null(group_name_element)) {
    group_name <- group_name_element %>% html_text()
    return(group_name)
  } else {
    stop("Group name element not found on the page.")
  }
}

ui <- dashboardPage(
  dashboardHeader(
    title = "Group Name Finder"
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Generate Group Cards", tabName = "generate_group_cards", icon = icon("search"))
    )
  ),
  dashboardBody(
    useShinyjs(),
    tabItems(
      tabItem(
        tabName = "generate_group_cards",
        fluidRow(
          box(
            title = "Enter Group ID",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            textInput("group_id_input", "Enter Group ID:", ""),
            actionButton("submit_button", "Get Group Name")
          ),
          box(
            title = "Group Name",
            status = "info",
            solidHeader = TRUE,
            width = 8,
            textOutput("group_name_output")
          ),
          box(
            title = "Card Title",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            textInput("card_title", "Enter Card Title:", "")
          ),
          box(
            title = "Generate Plot",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            actionButton("generate_plot_button", "Generate Plot")
          )
        ),
        fluidRow(
          box(
            title = "Card",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            plotOutput("card_chart", height = "500px") # Adjust the height as needed
          )
        ),
        fluidRow(
          box(
            title = "Download PDF",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            downloadButton("download_pdf", "Download PDF")
          )
        )
      )
    )
  )
)

server <- function(input, output) {
  
  # Create a reactiveValues to store the card
  rv <- reactiveValues(card = NULL)
  
  observeEvent(input$submit_button, {
    group_id <- input$group_id_input
    if (group_id != "") {
      url <- get_group_url(group_id)
      shinyjs::disable("submit_button") # Disable button during processing
      shinyjs::hide("group_name_output")
      shinyjs::show("loading_message")
      
      # Fetch the group name
      group_name <- get_group_name(url)
      
      shinyjs::hide("loading_message")
      shinyjs::show("group_name_output")
      output$group_name_output <- renderText({
        paste("Group Name:", group_name)
      })
      
      # Update the reactiveValues with the group name
      rv$group_name <- group_name
      
      shinyjs::enable("submit_button") # Re-enable button after processing
    }
  })
  
  observeEvent(input$generate_plot_button, {
    card_title <- input$card_title
    if (!is.null(card_title)) {
      group_name <- rv$group_name
      
      # Replace "\n" with actual line breaks
      card_title <- gsub("\\\\n", "\n", card_title)
      
      # Generate the card chart with the specified card title
      full_image <- get_logo(input$group_id_input)
      qr <- get_qr_code(input$group_id_input)
      cleaned_url <- gsub("^https://", "", get_group_url(input$group_id_input))
      p1 <- ggplot() + 
        geom_from_path(aes(path = full_image, x = 150, y = 150)) +
        theme_void() +
        labs(title = card_title, x = cleaned_url, y = "") +
        theme(plot.title = element_text(hjust = 0.5, margin = margin(0, 0, 0, 0), family = font, size = 12),
              axis.title.x = element_text(family = font, size = 10))
      
      title <- paste0("FUNDRAISER!!!\nSelect name under Leaderboard\nand shop!")
      p2 <- ggplot() + 
        geom_from_path(aes(path = qr, x = 150, y = 150), width = 0.49) +
        theme_void() +
        labs(title = title, x = "") +
        theme(plot.title = element_text(hjust = 0.5, margin = margin(0, 0, 0, 0), family = font, size = 10))
      
      card <- (p1 | p2)
      card <- card + theme(plot.margin = unit(c(4,4,4,0), "mm"), axis.title.x = element_text(margin = margin(0,0,0,0), family = font))
      
      # Update the reactiveValues with the card
      rv$card <- card
      
      output$card_chart <- renderPlot({
        card
      })
    }
  })
  
  output$download_pdf <- downloadHandler(
    filename = function() {
      paste0(toupper(input$group_id_input), ".pdf")
    },
    content = function(file) {
      # Create a card for download with specific modifications
      card_for_download <- rv$card + theme(plot.margin = unit(c(4,4,4,0), "mm"), axis.title.x = element_text(margin = margin(0,0,0,0), family = font))
      
      # Create a grid arrangement of the card for the PDF
      grid_arranged_plot <- wrap_plots(
        card_for_download, card_for_download, card_for_download,
        card_for_download, card_for_download, card_for_download,
        ncol = 2
      )
      
      # Save the PDF
      pdf(file, width = 10, height = 7) # Adjust width and height as needed
      print(grid_arranged_plot) # Print the grid arrangement of the card for download
      dev.off()
    }
  )
}

shinyApp(ui, server)
