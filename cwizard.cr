require "option_parser"
require "json"


# Docker
def list_docker_images
  cmd = "docker images --format '{{json .}}'"
  output = `#{cmd}`

  if $?.success?
    output_lines = output.split("\n")

    output_lines.each do |line|
      line = line.strip
      next if line.empty?

      begin
        image_data = JSON.parse(line)
        created = image_data["Created"]? || "N/A"

        puts "Repository: #{image_data["Repository"]} \n
        Tag: #{image_data["Tag"]} \n
        ID: #{image_data["ID"]} \n
        Created: #{created} \n
        Size: #{image_data["Size"]}"
        puts "-" * 30
      rescue exception : JSON::ParseException
        puts "Error parsing JSON output: \n
        #{exception.message}"

        puts "Raw Output: \n
        #{line}"
        puts "-" * 30
      end
    end
  else
    puts "Error running 'docker images' command: \n
    #{output}"
  end
end

def list_docker_containers
  cmd = "docker ps --format '{{json .}}'"
  output = `#{cmd}`

  if $?.success?
    output_lines = output.split("\n")

    output_lines.each do |line|
      line = line.strip
      next if line.empty?

      begin
        container_data = JSON.parse(line)
        status = container_data["Status"]? || "N/A"

        puts "Container ID: #{container_data["ID"]} \n
        Image: #{container_data["Image"]} \n
        Command: #{container_data["Command"]} \n
        Status: #{status} \n
        Ports: #{container_data["Ports"]}"
        puts "-" * 30
      rescue exception : JSON::ParseException
        puts "Error parsing JSON output: \n
        #{exception.message}"

        puts "Raw Output: \n
        #{line}"
        puts "-" * 30
      end
    end
  else
    puts "Error running 'docker ps' command: \n
    #{output}"
  end
end

# K8S
def kubectl_top_pod(namespace : String? = nil)
  # Ensure that the namespace is either a non-empty string or nil
  namespace = nil if namespace && namespace.strip.empty?

  # Construct the command based on the provided namespace
  cmd = namespace ? "kubectl top pod -n #{namespace}" : "kubectl top pod --all-namespaces"
  output = `#{cmd}`

  if $?.success?
    output_lines = output.split("\n")
    output_lines.shift # Skip the header line

    output_lines.each do |line|
      line = line.strip
      next if line.empty?

      columns = line.split(/\s+/)
      next if columns.size < (namespace ? 3 : 4)

      # Adjust the columns based on the presence of the namespace
      pod_name, cpu, memory = namespace ? [columns[0], columns[1], columns[2]] : [columns[1], columns[2], columns[3]]

      puts "Namespace: #{namespace || columns[0]} \n
      Pod Name: #{pod_name} \n
      CPU Usage: #{cpu} \n
      Memory Usage: #{memory}"
      puts "-" * 30
    end
  else
    puts "Error running 'kubectl top pod' command: \n
    #{output}"
  end
end

OptionParser.parse do |parser|
  parser.banner = "Welcome to The reLearn App!"

  parser.on "--version", "Show version" do
    puts "version 1.0"
    exit
  end

  parser.on "--help", "Show help" do
    puts parser
    exit
  end

  parser.on "--docker-images", "List Docker images" do
    list_docker_images
    exit
  end

  parser.on "--docker-containers", "List Docker containers" do
    list_docker_containers
    exit
  end

  parser.on "--kubectl-top-pod [NAMESPACE]", "List Kubernetes pods' resource usage" do |namespace|
    kubectl_top_pod(namespace)
    exit
  end
end

module TerminalColor
  RED = "\e[31m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN = "\e[36m"
  ORANGE = "\e[38;5;214m"
  RESET = "\e[0m"

  def self.colorize(text : String, color : String)
    "#{color}#{text}#{RESET}"
  end
end

def clear_screen
  {% if flag?(:win32) %}
    system "cls"
  {% else %}
    system "clear"
  {% end %}
end

def main_menu
  loop do
    clear_screen
    display_banner

    puts TerminalColor.colorize("Main Menu:", TerminalColor::CYAN)
    puts TerminalColor.colorize("1. Docker Operations", TerminalColor::YELLOW)
    puts TerminalColor.colorize("2. Kubernetes Operations", TerminalColor::YELLOW)
    puts TerminalColor.colorize("3. Template Operations", TerminalColor::YELLOW)
    puts TerminalColor.colorize("0. Exit", TerminalColor::RED)

    print TerminalColor.colorize("Enter your choice (1-3): ", TerminalColor::GREEN)
    choice = gets.try(&.to_i) || 0

    case choice
    when 1
      docker_menu
    when 2
      kubernetes_menu
    when 3
      template_menu
    when 0
      puts "Exiting..."
      break
    else
      puts TerminalColor.colorize("Invalid choice. Please enter a number between 1 and 3.", TerminalColor::RED)
    end

    puts TerminalColor.colorize("\nPress enter to continue...", TerminalColor::GREEN)
    gets
  end
end

def docker_menu
  loop do
    clear_screen
    display_banner

    puts TerminalColor.colorize("Docker Operations:", TerminalColor::CYAN)
    puts TerminalColor.colorize("1. List Docker Images", TerminalColor::YELLOW)
    puts TerminalColor.colorize("2. List Docker Containers", TerminalColor::YELLOW)
    puts TerminalColor.colorize("0. Return to Main Menu", TerminalColor::RED)

    print TerminalColor.colorize("Enter your choice (1-2): ", TerminalColor::GREEN)
    docker_choice = gets.try(&.to_i) || 0

    case docker_choice
    when 1
      list_docker_images
    when 2
      list_docker_containers
    when 0
      break
    else
      puts TerminalColor.colorize("Invalid choice. Please enter a number between 1 and 2.", TerminalColor::RED)
    end

    puts TerminalColor.colorize("\nPress enter to continue...", TerminalColor::GREEN)
    gets
  end
end

def kubernetes_menu
  loop do
    clear_screen
    display_banner

    puts TerminalColor.colorize("Kubernetes Operations:", TerminalColor::CYAN)
    puts TerminalColor.colorize("1. Get Pods with Labels", TerminalColor::YELLOW)
    puts TerminalColor.colorize("2. Describe Pods with Labels", TerminalColor::YELLOW)
    puts TerminalColor.colorize("3. Get Services in a Namespace", TerminalColor::YELLOW)
    puts TerminalColor.colorize("4. Get Deployments in a Namespace", TerminalColor::YELLOW)
    puts TerminalColor.colorize("5. Get StatefulSets in a Namespace", TerminalColor::YELLOW)
    puts TerminalColor.colorize("6. Get ConfigMaps in a Namespace", TerminalColor::YELLOW)
    puts TerminalColor.colorize("7. Get Ingress Resources in a Namespace", TerminalColor::YELLOW)
    puts TerminalColor.colorize("8. Watch Events in a Namespace", TerminalColor::YELLOW)
    puts TerminalColor.colorize("9. View Logs of a Pod", TerminalColor::YELLOW)
    puts TerminalColor.colorize("10. Delete a Kubernetes Resource", TerminalColor::YELLOW)
    puts TerminalColor.colorize("11. Scale a Deployment", TerminalColor::YELLOW)
    puts TerminalColor.colorize("12. Apply a YAML Configuration", TerminalColor::YELLOW)
    puts TerminalColor.colorize("0. Return to Main Menu", TerminalColor::RED)

    print TerminalColor.colorize("Enter your choice (1-12): ", TerminalColor::GREEN)
    k8s_choice = gets.try(&.to_i) || 0

    case k8s_choice
    when 1
      kubernetes_command_with_optional_namespace("get pods -l", true)
    when 2
      kubernetes_command_with_optional_namespace("describe pods -l", true)
    when 3
      kubernetes_command_with_optional_namespace("get svc", true)
    when 4
      kubectl_command_with_namespace("get deployments")
    when 5
      kubectl_command_with_namespace("get statefulsets")
    when 6
      kubectl_command_with_namespace("get configmaps")
    when 7
      kubectl_command_with_namespace("get ingress")
    when 8
      kubectl_watch_namespace("events")
    when 9
      view_pod_logs
    when 10
      delete_kubernetes_resource
    when 11
      scale_deployment
    when 12
      apply_yaml_configuration
    when 0
      break
    else
      puts TerminalColor.colorize("Invalid choice. Please enter a number between 1 and 12.", TerminalColor::RED)
    end

    puts TerminalColor.colorize("\nPress enter to continue...", TerminalColor::GREEN)
    gets
  end
end


def get_pods_with_labels
  print "Enter label selector: "
  label = gets.try(&.strip)
  system "kubectl get pods -l #{label}"
end

def describe_pods_with_labels
  print "Enter label selector: "
  label = gets.try(&.strip)
  system "kubectl describe pods -l #{label}"
end

def kubectl_command_with_namespace(command)
  print "Enter label selector: "
  label = gets.try(&.strip)
  print "Enter namespace (leave blank for all namespaces): "
  namespace = gets.try(&.strip)

  namespace_option = namespace && !namespace.empty? ? "-n #{namespace}" : "--all-namespaces"
  system "kubectl #{command} #{label} #{namespace_option}"
end

def kubernetes_command_with_optional_namespace(command : String, needs_label_selector : Bool = false)
  label_selector = ""
  if needs_label_selector
    print "Enter label selector: "
    label_selector = gets.try(&.strip)
  end

  print "Enter namespace (leave blank for all namespaces): "
  namespace = gets.try(&.strip)

  full_command = if namespace && !namespace.empty?
                  "kubectl #{command} -n #{namespace} #{label_selector}"
                else
                  # For commands without namespace, avoid using label selector
                  needs_label_selector ? "kubectl #{command} --all-namespaces" : "kubectl #{command}"
                end

  system full_command
end

def kubectl_watch_namespace(resource : String)
  print "Enter namespace (leave blank for all namespaces): "
  namespace = gets.try(&.strip)

  namespace_option = namespace && !namespace.empty? ? "-n #{namespace}" : "--all-namespaces"

  # Trap SIGINT in this block to prevent the entire app from closing
  Signal::INT.trap do
    puts "\nStopped watching #{resource}."
  end

  system "kubectl get #{resource} #{namespace_option} --watch"

  # Reset the SIGINT trap to the default behavior
  Signal::INT.reset
end

def view_pod_logs
  print "Enter Pod name: "
  pod_name = gets.try(&.strip)
  print "Enter namespace (leave blank for default): "
  namespace = gets.try(&.strip)
  namespace_option = namespace && !namespace.empty? ? "-n #{namespace}" : ""
  system "kubectl logs #{pod_name} #{namespace_option}"
end

def delete_kubernetes_resource
  puts TerminalColor.colorize("Not implemented yet.", TerminalColor::ORANGE)
end

def scale_deployment
  puts TerminalColor.colorize("Not implemented yet.", TerminalColor::ORANGE)
end

def apply_yaml_configuration
  puts TerminalColor.colorize("Not implemented yet.", TerminalColor::ORANGE)
end



def template_menu
  # Similar structure to docker_menu
end

def display_banner
  puts TerminalColor.colorize("====================================", TerminalColor::CYAN)
  puts TerminalColor.colorize("   Welcome to The cWizard App!", TerminalColor::MAGENTA)
  puts TerminalColor.colorize("         Version 1.0", TerminalColor::GREEN)
  puts TerminalColor.colorize("   © 2024 Denis Tu.", TerminalColor::YELLOW)
  puts TerminalColor.colorize("====================================", TerminalColor::CYAN)
end

main_menu
